![alula hero](https://github.com/MrKai77/Alula/blob/main/Assets/alula_hero.png)

## Inspiration

Did you know that over 1200 bird species across the world are currently threatened, vulnerable, or endangered, per the IUCN Red List? Or that the bird population in North America has dropped by 3 BILLION since 1970? These are only two of *many* unfortunate statistics, of which the root cause is human action - or human *inaction* in the face of climate change.

This spurred us to create *alula* - an AI-powered tool to help bring awareness of birds and bird conservation efforts to anyone and everyone. The name *alula* comes from the word that refers to a bird's thumb - a small set of feathers on the frontmost edge of the wing. This biological structure prevents wing stalling by creating vortices in the air, streamlining bird flight. In the same way, we aim to streamline education and awareness surrounding avian conservation efforts.

## What it does

*alula* uses an image classification model to identify any species of bird from a single image. It allows users to catalogue images of their identified birds and share them with friends. *alula* also features gamification to enhance the user learning experience, with a leaderboard of users ranked by the number of birds identified and achievements that are unlocked by completing specific bird identification tasks.

## How we built it

*alula*'s image classification model was trained using the NABirds V1 dataset from the Cornell Lab of Ornithology, which features over 48,000 pictures of over 1,000 bird species. The model was trained with Create ML over 25 iterations with noise, blur, crop, expose, flip, and rotate augmentations, then used in Xcode using both the CoreML and Vision frameworks.

Friends and achievements were both created as separate tables in a relational database hosted on Supabase, which is accessed by the frontend.

Bird information, such as IUCN Red List status and habitat information, was obtained using the Wikipedia API and the GBIF API and stored in a table on Supabase.

The frontend was created entirely in SwiftUI, with various assets designed using Affinity Suite.

## Challenges we ran into

The IUCN Red List API proved difficult to use due to their transitioning of their API from v3 or v4. v4 was not completely fleshed out, preventing us from accessing conservation status using a bird's common name, but v3 was no longer accessible due to being retired in July 2024.

## Accomplishments that we're proud of

We're proud of how we built this application using a complete Apple stack, from the image classification to the frontend. We were also very excited about how efficient Supabase makes backend work.

## What we learned

We learned how to use Core ML, Supabase, and the Wikipedia and GBIF APIs over the course of this hackathon.

## What's next for alula

We'd love to access larger datasets to further improve our model's accuracy, and implement more community-building features such as group birdwatching and bird identification events.
