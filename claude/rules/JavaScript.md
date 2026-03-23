# Front-End JavaScript Best Practices

## Prime Directive: Stupid Simple Code

Write code that a tired developer at 2am can read and understand immediately. Clever code is bad code. Simple code is good code. If you have to think hard to understand what a line does, rewrite it.

## Naming

- Variables and functions: use descriptive, full English words. `getUserEmail()` not `getUE()`. `isVisible` not `iv`.
- Booleans start with `is`, `has`, `can`, `should`: `isLoading`, `hasError`, `canSubmit`.
- Event handlers start with `handle` or `on`: `handleClick`, `onSubmit`.
- Name things for what they ARE or what they DO, never for how they're implemented.

## Functions

- Each function does ONE thing. If you're describing what a function does and you use the word "and", split it into two functions.
- Keep functions short. If it doesn't fit on one screen (~30 lines), break it up.
- Prefer named functions over anonymous ones. Named functions show up in stack traces and are easier to search for.
- Avoid nesting more than 2 levels deep. Use early returns to flatten logic.
- No magic numbers or magic strings. Use named constants.

```js
// BAD
if (status === 3) { ... }

// GOOD
const STATUS_COMPLETE = 3;
if (status === STATUS_COMPLETE) { ... }
```

## Variables

- Use `const` by default. Use `let` only when you need to reassign. Never use `var`.
- Declare variables close to where they're used, not at the top of a function.
- One variable per declaration. No `let a = 1, b = 2`.

## Control Flow

- Prefer early returns over deeply nested if/else chains.
- Use guard clauses at the top of functions to handle edge cases first.

```js
// BAD
function process(user) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        // actual logic buried 3 levels deep
      }
    }
  }
}

// GOOD
function process(user) {
  if (!user) return;
  if (!user.isActive) return;
  if (!user.hasPermission) return;

  // actual logic at the top level
}
```

## DOM Manipulation

- Cache DOM lookups. Don't call `document.querySelector` for the same element repeatedly.
- Prefer `textContent` over `innerHTML` unless you need to insert HTML. It's safer and faster.
- Use event delegation on parent elements instead of attaching listeners to many child elements.
- Batch DOM writes together to avoid layout thrashing. Read first, then write.

## Events

- Always clean up event listeners when elements are removed. If you `addEventListener`, plan for `removeEventListener`.
- Use `AbortController` for cleanly removing groups of listeners.
- Prefer `addEventListener` over `onclick` attributes.

## Async Code

- Use `async/await` over `.then()` chains. It reads top to bottom like normal code.
- Always handle errors with try/catch around await calls.
- Never use `async` on a function that doesn't `await` anything.
- If you fire off a promise without awaiting it, add a `.catch()` so errors don't vanish silently.

```js
// BAD
fetchData().then(data => {
  return processData(data);
}).then(result => {
  updateUI(result);
}).catch(err => {
  handleError(err);
});

// GOOD
async function loadAndDisplay() {
  try {
    const data = await fetchData();
    const result = processData(data);
    updateUI(result);
  } catch (err) {
    handleError(err);
  }
}
```

## Error Handling

- Never swallow errors silently. At minimum, log them.
- Provide helpful error messages that say what went wrong AND what the expected state was.
- Use try/catch at boundaries (event handlers, async calls), not around every single line.

## Modules and Imports

- One module = one responsibility.
- Keep imports at the top of the file, grouped: third-party first, then local.
- Prefer named exports over default exports. They're easier to search for and refactor.

## Comments

- Don't comment WHAT the code does (the code itself should be clear enough). Comment WHY it does something non-obvious.
- If you need a comment to explain what code does, rewrite the code to be clearer instead.
- TODOs are fine but include context: `// TODO(2025-04): remove after migration is complete`

## State Management

- Keep state as local as possible. Don't make things global unless you have a strong reason.
- Derive values from state instead of storing computed results as separate state. One source of truth.
- When managing complex state, use a simple object with clear update functions rather than scattered variables.

## Security

- Never use `eval()`, `Function()`, or `setTimeout`/`setInterval` with string arguments. There is almost always a better way.
- Never build HTML with string concatenation or template literals from user input. Use `textContent`, DOM APIs, or a framework's built-in escaping.
- Sanitize and validate all user input before using it — on the client AND the server. Client-side validation is for UX, not security.
- Never store sensitive data (tokens, passwords, PII) in `localStorage` or `sessionStorage`. They're accessible to any script on the page. Use `httpOnly` cookies for auth tokens.
- Use `Content-Security-Policy` headers. Avoid `unsafe-inline` and `unsafe-eval` whenever possible.
- When using `fetch`, never interpolate user input directly into URLs without encoding it with `encodeURIComponent`.
- Be cautious with `innerHTML`, `outerHTML`, `insertAdjacentHTML`, and `document.write`. All of them can execute injected scripts. Prefer safe DOM APIs.
- When using `postMessage`, always check `event.origin` against an allowlist. Never trust messages blindly.
- Never put secrets (API keys, tokens, credentials) in client-side JavaScript. Anything in the browser is visible to the user.
- When loading third-party scripts, use `integrity` attributes (Subresource Integrity) so tampered scripts won't execute.
- Treat every piece of data from outside your code (user input, URL params, API responses, `postMessage`) as untrusted until validated.

## General Rules

- Avoid ternaries more than one level deep. Nested ternaries are unreadable.
- Avoid `==`. Always use `===`.
- Don't use `this` unless you're in a class and you truly need it. Arrow functions and closures are usually simpler.
- No premature optimization. Write it simple first. Optimize only when there's a measured performance problem.
- Prefer `for...of` over `forEach` when you don't need the index and might want to `break` or `return` early.
- Keep third-party dependencies to a minimum. Every dependency is code you don't control.
- If the browser has a built-in API that does what you need, use it instead of a library.
