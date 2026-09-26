You are an expert software engineer and technical educator.

Read the entire codebase and create a Markdown (`.md`) document explaining **how the system works from a high level**.

Do NOT document the code file-by-file or function-by-function.

Instead, reverse-engineer the code into the **major jobs the system performs to produce its final result**, then explain how each of those jobs works.

Make it stupid simple to understand.

The goal is for someone to finish the document and think:

"Okay, I understand what this thing does, the major steps it goes through, why those steps exist, and how it ultimately produces the result."

Assume the reader is technical enough to understand basic software concepts, but has never seen this codebase before.

# What to Figure Out

First, inspect the entire codebase and determine:

* What is the system ultimately trying to accomplish?
* What goes into the system?
* What final result comes out?
* What are the major jobs/stages required to get from input to output?
* In what order do those jobs happen?
* How does each job actually work?
* What decisions, transformations, calculations, filtering, validation, or processing happen along the way?
* What important external systems, APIs, databases, models, or libraries are involved?
* How do the major pieces connect?

Think in terms of a pipeline such as:

**Input → Preparation → Processing → Decision Making → Transformation → Output**

That is only an example. Determine the real workflow from the code.

# How to Explain It

Focus on **behavior and process**, not implementation trivia.

For every major job/stage, explain:

1. **What it does**
2. **Why the system needs to do it**
3. **What information it starts with**
4. **How it performs the job**
5. **What important decisions or transformations happen**
6. **What it produces**
7. **What happens with that result next**

Explain the actual mechanism when it matters.

For example, don't just write:

"The system ranks the results."

Explain something like:

"Once the initial candidates are collected, the system assigns each one a score based on X, Y, and Z. Candidates that fail X are removed first. The remaining candidates are sorted by their combined score, and the highest-ranking results are passed to the next stage."

The reader should understand the **logic of the system** without needing to understand every function implementing that logic.

# Level of Detail

Stay at the **system/workflow level**.

Mention specific files, classes, functions, or code snippets only when they help prove or clarify how an important part of the system works.

Do NOT create:

* A function-by-function reference
* A class-by-class reference
* A tedious file-by-file walkthrough
* Documentation for obvious boilerplate
* Exhaustive descriptions of implementation details

Instead, group implementation details into the larger **jobs they accomplish**.

Several files and functions may work together to perform one job. Explain them as one conceptual stage.

# Markdown Structure

Use the following general structure, adapting it when the codebase suggests a better organization.

# How This System Works

## 1. What It Does

Explain the system's purpose in very simple terms.

Clearly identify:

**Input → What the system does → Final output**

## 2. The Whole Process in 60 Seconds

Give a short numbered walkthrough of the entire process from beginning to end.

Someone who reads only this section should understand the basic workflow.

Include a simple flowchart (NOT mermaid) if it makes the process easier to visualize.

## 3. The Major Jobs

Identify the major jobs/stages the system performs.

For each stage, create a section such as:

### Job 1: [Plain-English Name]

Explain:

* What is happening
* Why it needs to happen
* How the system accomplishes it
* Important rules or decisions involved
* What comes out of this stage
* Where that output goes next

Then continue through Job 2, Job 3, etc., until the final result is produced.

Spend more time on stages containing important business logic, algorithms, transformations, or unusual behavior.

## 4. How the Pieces Work Together

Explain how the major stages depend on one another.

Focus especially on how information produced by one stage becomes the input to another.

## 5. Important External Pieces

Explain any important APIs, databases, AI models, services, frameworks, or other external dependencies.

Focus on **what role they play in the overall process**, rather than documenting their APIs.

## 6. End-to-End Example

Create one realistic example input and follow it through the entire system.

Show what happens to it at each major stage until the final output is produced.

Base the example on behavior supported by the code. Do not invent capabilities that aren't present.

## 7. The Simplest Mental Model

Finish with a concise explanation of the system that reduces everything to its essential idea.

Explain it almost like you were describing the machinery:

"It takes X, does A to it, uses B to determine C, passes that through D, and ultimately produces Y."

# Important Rules

* Read enough of the codebase to understand the actual end-to-end behavior before writing.
* Explain **what the code accomplishes**, not merely what code exists.
* Group related implementation details by the job they collectively perform.
* Prioritize the main path through the system.
* Explain important branches or alternative paths when they materially change the result.
* Skip implementation details that don't help someone understand the overall system.
* Use plain English.
* Define unavoidable technical terms.
* Use concrete examples whenever they make a complicated process easier to understand.
* Do not guess. Clearly identify anything that cannot be determined from the code.
* Do not confuse configuration or boilerplate with core system behavior.
* Do not expose secrets, credentials, tokens, or sensitive values.

The final Markdown document should make the reader feel like they understand the **machinery of the system** without requiring them to understand the individual functions that implement it.
