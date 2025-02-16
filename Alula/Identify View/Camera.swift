//
//  Camera.swift
//  Alula
//
//  Created by Kai Azim on 2025-02-15.
//

import AVFoundation
import CoreImage
import os.log
import UIKit

// MARK: - CaptureSessionActor

// By having a dedicated actor for the capture session, we can ensure that the capture session is only accessed from a single thread.
actor CaptureSessionActor {
    private let captureSession: AVCaptureSession = .init()

    func beginConfiguration() {
        captureSession.beginConfiguration()
    }

    func commitConfiguration() {
        captureSession.commitConfiguration()
    }

    @discardableResult
    func addInput(_ input: AVCaptureDeviceInput) -> Bool {
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            return true
        } else {
            return false
        }
    }

    @discardableResult
    func addOutput(_ output: AVCaptureOutput) -> Bool {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            return true
        } else {
            return false
        }
    }

    func removeAllInputs() {
        for case let input as AVCaptureDeviceInput in captureSession.inputs {
            captureSession.removeInput(input)
        }
    }

    func startRunning() {
        captureSession.startRunning()
    }

    func stopRunning() {
        captureSession.stopRunning()
    }

    var isRunning: Bool {
        captureSession.isRunning
    }
}

// MARK: - Camera

final class Camera: NSObject {
    // MARK: Properties

    private let sessionQueue: DispatchQueue = .init(label: "com.MrKai77.Spectra.CameraQueue")
    private let sessionActor = CaptureSessionActor()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?

    // MARK: Capture Devices

    var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName) with zoom factor \(captureDevice.videoZoomFactor)")

            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }

    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return captureDevice.position == .front
    }

    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return captureDevice.position == .back
    }

    // MARK: Streams

    private var addToPhotoStream: ((AVCapturePhoto) -> ())?

    private var addToPreviewStream: ((CIImage) -> ())?

    lazy var previewStream: AsyncStream<CIImage> = AsyncStream { continuation in
        addToPreviewStream = { ciImage in
            continuation.yield(ciImage)
        }
    }

    lazy var photoStream: AsyncStream<AVCapturePhoto> = AsyncStream { continuation in
        addToPhotoStream = { photo in
            continuation.yield(photo)
        }
    }

    // MARK: Initialization

    override init() {
        super.init()
        self.captureDevice = AVCaptureDevice.bestCaptureDevice(for: .back)

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateForDeviceOrientation),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    // MARK: Start/Stop

    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }

        if isCaptureSessionConfigured {
            // If already configured and not running, start it.
            if !(await sessionActor.isRunning) {
                await sessionActor.startRunning()
            }
            return
        }

        // Configure the capture session.
        let success = await configureCaptureSession()
        if success {
            await sessionActor.startRunning()
        }
    }

    func stop() async {
        guard isCaptureSessionConfigured else { return }

        if await sessionActor.isRunning {
            await sessionActor.stopRunning()
        }
    }

    // MARK: Zooming

    @discardableResult
    func setZoomFactor(to factor: CGFloat) -> CGFloat? {
        guard let captureDevice = captureDevice else {
            print("No virtual device found.")
            return nil
        }

        if captureDevice.isVirtualDevice {
            let factor = factor * captureDevice.standardZoomFactor
            let minFactor = captureDevice.minAvailableVideoZoomFactor
            let maxFactor = captureDevice.maxAvailableVideoZoomFactor
            let clampedFactor = max(minFactor, min(factor, maxFactor))

            do {
                try captureDevice.lockForConfiguration()
                captureDevice.videoZoomFactor = clampedFactor
                captureDevice.unlockForConfiguration()
            } catch {
                print("Failed to set zoom for virtual device: \(error.localizedDescription)")
            }

            return clampedFactor / captureDevice.standardZoomFactor
        } else {
            let minFactor = captureDevice.minAvailableVideoZoomFactor
            let maxFactor = captureDevice.maxAvailableVideoZoomFactor
            let clampedFactor = max(minFactor, min(factor, maxFactor))

            do {
                try captureDevice.lockForConfiguration()
                captureDevice.videoZoomFactor = clampedFactor
                captureDevice.unlockForConfiguration()
            } catch {
                print("Failed to set zoom for virtual device: \(error.localizedDescription)")
            }

            return clampedFactor
        }
    }

    // MARK: Camera Position

    func setCameraPosition(to position: AVCaptureDevice.Position) {
        guard let captureDevice = AVCaptureDevice.bestCaptureDevice(for: position) else { return }
        self.captureDevice = captureDevice
    }

    // MARK: Configuration

    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }

    private func configureCaptureSession() async -> Bool {
        var success = false

        await sessionActor.beginConfiguration()

        guard let captureDevice = captureDevice,
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error("Failed to obtain video input.")
            await sessionActor.commitConfiguration()
            return success
        }

        let photoOutput = AVCapturePhotoOutput()
        let videoOutput = AVCaptureVideoDataOutput()

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))

        guard await sessionActor.addInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            await sessionActor.commitConfiguration()
            return success
        }

        guard await sessionActor.addOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            await sessionActor.commitConfiguration()
            return success
        }

        guard await sessionActor.addOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            await sessionActor.commitConfiguration()
            return success
        }

        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput

        photoOutput.maxPhotoDimensions = captureDevice.maxPhotoDimensions
        photoOutput.maxPhotoQualityPrioritization = .quality

        updateVideoOutputConnection()

        isCaptureSessionConfigured = true
        success = true

        await sessionActor.commitConfiguration()

        return success
    }

    private func updateVideoOutputConnection() {
        guard let videoOutput = videoOutput,
              let videoOutputConnection = videoOutput.connection(with: .video)
        else {
            return
        }

        if videoOutputConnection.isVideoMirroringSupported {
            videoOutputConnection.isVideoMirrored = self.isUsingFrontCaptureDevice
        }

        let rotation = UIScreen.main.orientation.cameraAngle

        if videoOutputConnection.isVideoRotationAngleSupported(rotation) {
            videoOutputConnection.videoRotationAngle = rotation
        }

        setZoomFactor(to: 1.0)
    }

    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }

        sessionQueue.async {
            Task {
                await self.sessionActor.beginConfiguration()
                // Remove all inputs.
                await self.sessionActor.removeAllInputs()
                // Create a new input for the provided device.
                if let newDeviceInput = self.deviceInputFor(device: captureDevice) {
                    if await self.sessionActor.addInput(newDeviceInput) {
                        self.deviceInput = newDeviceInput
                    }
                }
                self.updateVideoOutputConnection()
                await self.sessionActor.commitConfiguration()
            }
        }
    }

    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: Photo Capture

    func takePhoto() {
        guard let photoOutput = photoOutput else { return }

        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()

            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }

            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off

            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }

            if let captureDevice = self.captureDevice {
                photoSettings.maxPhotoDimensions = captureDevice.maxPhotoDimensions
            }

            photoSettings.photoQualityPrioritization = .quality

            if let photoOutputConnection = photoOutput.connection(with: .video) {
                // Note that UIDevice.current.orientation is used instead of UIScreen.main.orientation.
                // This is because Spectra is set to only support portrait mode,
                // so we can rely on the device's orientation when capturing photos.
                let rotation = UIDevice.current.orientation.cameraAngle

                if photoOutputConnection.isVideoRotationAngleSupported(rotation) {
                    photoOutputConnection.videoRotationAngle = rotation
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    func getMaxPhotoDimensions() -> CMVideoDimensions? {
        guard let captureDevice = captureDevice else {
            logger.error("Capture device is nil when getting max dimensions")
            return nil
        }

        let captureDeviceFormat = captureDevice.activeFormat
        let maxPhotoDimensions = captureDeviceFormat.supportedMaxPhotoDimensions[0]

        return maxPhotoDimensions
    }

    @objc
    func updateForDeviceOrientation() {
        guard let videoOutput = videoOutput,
              let videoOutputConnection = videoOutput.connection(with: .video)
        else {
            return
        }

        let rotation = UIScreen.main.orientation.cameraAngle

        if videoOutputConnection.isVideoRotationAngleSupported(rotation) {
            videoOutputConnection.videoRotationAngle = rotation
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }

        addToPhotoStream?(photo)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        let rotation = UIScreen.main.orientation.cameraAngle

        if connection.isVideoRotationAngleSupported(rotation) {
            connection.videoRotationAngle = rotation
        }

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

// MARK: - AVCaptureDevice Extensions

extension AVCaptureDevice {
    static func bestCaptureDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // Multi-lens/logical device, ultra-wide & wide & telephoto
        if let device = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: position) {
            return device
        }

        // Multi-lens/logical device, ultra-wide & wide
        if let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: position) {
            return device
        }

        // Multi-lens/logical device, wide & telephoto (no ultra-wide)
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            return device
        }

        // Single-lens/physical device
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        }

        // TrueDepth, front-facing
        if let device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: position) {
            return device
        }

        return AVCaptureDevice.default(for: .video)
    }

    var standardZoomFactor: CGFloat {
        let fallback = 1.0

        // Devices that have multiple physical cameras are hidden behind one virtual camera input.
        // The zoom factor defines what physical camera is actually used.
        if let wideAngleIndex = constituentDevices.firstIndex(where: { $0.deviceType == .builtInWideAngleCamera }) {
            // .virtualDeviceSwitchOverVideoZoomFactors has the .constituentDevices zoom factor which borders the NEXT device
            // so we grab the one PRIOR to the wide angle to get the wide angle's zoom factor
            guard wideAngleIndex >= 1 else { return fallback }
            return virtualDeviceSwitchOverVideoZoomFactors[wideAngleIndex - 1].doubleValue
        }

        return fallback
    }

    var maxPhotoDimensions: CMVideoDimensions {
        activeFormat.supportedMaxPhotoDimensions[0]
    }
}

// MARK: - UIScreen Orientation Angle

extension UIScreen {
    var orientation: UIDeviceOrientation {
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        if point == CGPoint.zero {
            return .portrait
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight //.landscapeLeft
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft //.landscapeRight
        } else {
            return .unknown
        }
    }
}

extension UIDeviceOrientation {
    var cameraAngle: CGFloat {
        switch self {
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return 270
        case .landscapeLeft:
            return 0
        case .landscapeRight:
            return 180
        default:
            return 90 // Default to portrait
        }
    }
}

private let logger: Logger = .init(subsystem: "com.MrKai77.Alula", category: "Camera")
