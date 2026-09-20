Separately identify the "paranoid" stuff—checks, validation, retries, verification, cleanup protections, etc.—and ask: What actual failure is this protecting us from? If there's no good answer, it's probably complexity we can remove.

Find defensive code, fallbacks, abstractions, compatibility paths, validation, and recovery logic that aren't justified by an actual requirement or realistic failure mode.
