# EasyRise — Batch 1: Get it building and running on your phone

You now have a real, working alarm app with a math-puzzle dismiss screen and
a streak tracker. Here's exactly what to click to see it running.

## Step 1 — Upload to GitHub (2 minutes)

1. Unzip `easyrise-app.zip` on your computer — you'll get a folder called `easyrise`.
2. Go to https://github.com/new
3. Repository name: `easyrise` (or anything you like)
4. **Set visibility to Private** — important, since your signing key lives in this repo.
5. Click **Create repository**.
6. On the next page, click **"uploading an existing file"**.
7. Open the `easyrise` folder on your computer, select **everything inside it**
   (not the folder itself — its *contents*: `lib`, `android`, `pubspec.yaml`, etc.)
   and drag them into the GitHub upload box.
8. Scroll down, click **Commit changes**.

⚠️ One nuance: GitHub's web uploader sometimes struggles with deeply nested
empty-looking folders. If `android/gradle/wrapper/gradle-wrapper.jar` doesn't
show up in the repo after upload, that's the most common thing to double check —
just drag that specific file in separately if needed.

## Step 2 — Connect Codemagic (2 minutes)

1. Go to https://codemagic.io and sign up using **"Sign in with GitHub"** — this
   auto-connects your repos, no extra config.
2. On your dashboard, find the `easyrise` repo and click **Set up build**.
3. Codemagic will detect the `codemagic.yaml` file already in the repo and offer
   a workflow called **"EasyRise Android Release"** — select it.
4. Click **Start new build**.
5. Wait ~5–8 minutes. You'll see live logs.

## Step 3 — Get your installable file

1. When the build finishes (green checkmark), scroll to **Artifacts**.
2. Download the `.aab` file — this is what goes to Play Store.
3. Also download the `.apk` file — install this directly on your own Android
   phone to test the app before publishing anything (just transfer it to
   your phone and tap to install; you may need to allow "install from
   unknown sources" once).

## Step 4 — Before you upload to Play Console

A couple of things worth deciding now, since they're easy to change before
launch and annoying after:

- **Package name**: I set it to `com.easyrise.alarmapp`. This is permanent
  once you publish — Google will never let you change it. If you'd rather
  use your own domain/name (e.g. `com.yourname.easyrise`), tell me before
  you do your first Play Console upload and I'll update the project (it's
  a find-and-replace across ~4 files, takes me a minute).
- **App name shown to users**: currently "EasyRise" — easy to change anytime,
  just say the word.

## What Batch 1 actually gives you right now

- Add/edit/delete alarms, with repeat days and a difficulty picker
- Alarms fire reliably even if the app is closed (uses Android's foreground
  service + exact alarm scheduling — the same mechanism real alarm-clock
  apps use)
- Full-screen math puzzle to dismiss — can't be swiped away, back button
  disabled during ringing
- A satisfying streak counter + GitHub-style "chain" visual on the home screen
- Soft mint/pink theme throughout

## What's coming in later batches (per our roadmap)

- Batch 2: more puzzle types (shake-to-solve, memory sequence, typing)
- Batch 3: onboarding + permission-request screens that explain *why* each
  permission is needed (improves Play Store approval odds and user trust)
- Batch 4: settings screen, dark mode, custom alarm sounds
- Batch 5: store listing — screenshots, description, feature graphic
- Batch 6: submission walkthrough inside Play Console itself

## Your keystore backup

I've also generated `KEYSTORE-BACKUP-KEEP-SAFE.txt` — save that somewhere
private (password manager, notes app, wherever you keep sensitive things).
You don't need to do anything with it today; it's just your insurance policy.

---

Once you've got a build running, install the `.aab` on a test device (or
tell me you want a `.apk` build added for easier sideloading) and try it —
set an alarm for 2 minutes from now and see the puzzle screen fire. Let me
know how it goes and we'll move to Batch 2.
