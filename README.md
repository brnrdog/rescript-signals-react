# rescript-signals-react

Proof-of-concept adapter bridging [`rescript-signals`](https://github.com/brnrdog/rescript-signals) (reactive signals for ReScript) to [`rescript-react`](https://github.com/rescript-lang/rescript-react) via React 18's `useSyncExternalStore`.

## Why

`rescript-signals` gives you a fine-grained reactive graph: `Signal`, `Computed`, `Effect`, with a disposer-returning effect primitive. React components don't know how to subscribe to that graph on their own. This package is the glue.

## Install (once published)

```sh
npm install rescript-signals-react rescript-signals @rescript/react react react-dom
```

Then add `rescript-signals-react` (and its peers) to `dependencies` in your `rescript.json`.

## API

```rescript
open Signals

let useSignalValue: Signal.t<'a> => 'a
let useSignal: (unit => 'a) => ('a, Signal.t<'a>, 'a => unit)
let useComputed: (unit => 'a) => 'a
let useComputedWithDeps: (unit => 'a, 'deps) => 'a
let useSignalEffect: (unit => option<unit => unit>) => unit
```

- `useSignalValue` subscribes to an existing signal and returns its value.
- `useSignal` mirrors `useState`'s shape but returns the underlying `Signal.t` as well, so siblings can subscribe without prop drilling.
- `useComputed` / `useComputedWithDeps` wrap `Computed.make`. Use the `WithDeps` variant when the thunk closes over React props or `useState` values.
- `useSignalEffect` runs a tracked effect scoped to the component's lifetime; return `Some(cleanup)` for per-run cleanup.

## Usage

```rescript
open Signals
let count = Signal.make(0)

@react.component
let make = () => {
  let value = SignalsReact.useSignalValue(count)
  <button onClick={_ => Signal.update(count, c => c + 1)}>
    {React.string(Int.toString(value))}
  </button>
}
```

Derived:

```rescript
let fullName = SignalsReact.useComputed(() =>
  Signal.get(first) ++ " " ++ Signal.get(last)
)
```

Local state with the `useState` shape plus a stable signal handle:

```rescript
let (draft, draftSignal, setDraft) = SignalsReact.useSignal(() => "")
```

## How it works

Inside `useSignalValue` the adapter installs an `Effect.runWithDisposer` observer whose body reads the signal (establishing dependency tracking) and forwards subsequent notifications to React's `useSyncExternalStore` listener. `getSnapshot` uses `Signal.peek` so the read is non-tracking. React's `Object.is` bail-out on snapshot equality means unchanged signals don't rerender.

```rescript
let subscribe = React.useCallback1(listener => {
  let firstRun = ref(true)
  let disposer = Effect.runWithDisposer(() => {
    let _ = Signal.get(signal)
    if firstRun.contents { firstRun := false } else { listener() }
    None
  })
  () => disposer.dispose()
}, [signal])
```

The `firstRun` flag avoids notifying React on the initial synchronous run that `Effect.runWithDisposer` does to prime tracking.

## What we borrowed from `@preact/signals-react`

This PoC is deliberately API-compatible in shape with Preact's binding where it made sense. Specifically:

- **Hook names and signatures** — `useSignal`, `useComputed`, `useSignalEffect` come directly from [`@preact/signals-react`'s public API](https://github.com/preactjs/signals/tree/main/packages/react#hooks). The return shape of `useSignal` is extended to expose the underlying `Signal.t`, but the ergonomic goal is the same.
- **Subscription strategy** — Preact's React runtime (`_useSignalsImplementation` in [`packages/react/runtime/src/index.ts`](https://github.com/preactjs/signals/blob/main/packages/react/runtime/src/index.ts)) bridges signals to React with `useSyncExternalStore`, using a version counter as the snapshot and a reactive effect to call the listener. We use the same primitive, with `Signal.peek` as the snapshot and `Effect.runWithDisposer` as the reactive effect. The mechanics of subscribe/dispose map 1:1.
- **Effect lifecycle pattern** — `useSignalEffect` wrapping `Effect.runWithDisposer` under a `useEffect` with disposer cleanup matches the pattern in [`packages/react/src/index.ts`](https://github.com/preactjs/signals/blob/main/packages/react/src/index.ts) (`effect` called inside `useMemo`, disposer returned from `useEffect`).

What we did **not** take from Preact:

- No Babel transform (`@preact/signals-react-transform`). Subscriptions are explicit per hook call.
- No auto-tracking `useSignals()` marker that subscribes a whole component to every signal it reads.
- No `useLiveSignal`, `useSignalRef`, `useModel`, `<Show>`, `<For>` helpers — out of scope for the PoC.

## Demos

- `src/demo/Counter.res` — basic signal read + write.
- `src/demo/DerivedDemo.res` — `useComputed` from two signals.
- `src/demo/WriteDemo.res` — component-local signals via `useSignal`, batched writes.

## Build & run

```sh
npm install
npm run res:build   # ReScript compile
npm run dev         # Vite dev server
```

## Caveats

See the design notes in the original PoC discussion for the full list. The important ones:

- React 18+ only (`useSyncExternalStore` is the bridge).
- Don't call `Signal.set` during render.
- Props captured inside a `useComputed` thunk go stale; use `useComputedWithDeps` or promote the prop into a signal.
- Each `useSignalValue` call opens its own observer. Fine for normal UIs, worth knowing for benchmarks.

## Status

Proof of concept. Not published. Not production hardened. See "Next steps" in the design doc for what a real package would need.
