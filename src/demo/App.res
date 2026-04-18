let code = (src: string) =>
  <pre>
    <code> {React.string(src)} </code>
  </pre>

let counterCode = `open Signals

let countSignal = Signal.make(0)

@react.component
let make = () => {
  let count = SignalsReact.useSignalValue(countSignal)

  <section>
    <h2> {React.string("Basic signal")} </h2>
    <p> {React.string(\`Count: \${Int.toString(count)}\`)} </p>
    <button onClick={_ => Signal.update(countSignal, c => c + 1)}>
      {React.string("Increment")}
    </button>
    <button onClick={_ => Signal.set(countSignal, 0)}>
      {React.string("Reset")}
    </button>
  </section>
}`

let derivedCode = `open Signals

let first = Signal.make("Ada")
let last = Signal.make("Lovelace")

@react.component
let make = () => {
  let fullName = SignalsReact.useComputed(() =>
    Signal.get(first) ++ " " ++ Signal.get(last)
  )
  let firstValue = SignalsReact.useSignalValue(first)
  let lastValue = SignalsReact.useSignalValue(last)

  <section>
    <h2> {React.string("Derived / computed signal")} </h2>
    <p> {React.string(\`Full name: \${fullName}\`)} </p>
    <label>
      {React.string("First ")}
      <input
        value=firstValue
        onChange={e => Signal.set(first, (e->JsxEvent.Form.target)["value"])}
      />
    </label>
    <label>
      {React.string("Last ")}
      <input
        value=lastValue
        onChange={e => Signal.set(last, (e->JsxEvent.Form.target)["value"])}
      />
    </label>
  </section>
}`

let writeCode = `open Signals

@react.component
let make = () => {
  let (items, itemsSignal, _) = SignalsReact.useSignal(() => list{})
  let (draft, _, setDraft) = SignalsReact.useSignal(() => "")

  let addItem = _ => {
    let trimmed = String.trim(draft)
    if trimmed != "" {
      Signal.batch(() => {
        Signal.update(itemsSignal, xs => list{trimmed, ...xs})
        setDraft("")
      })
    }
  }

  <section>
    <h2> {React.string("Write / update flow")} </h2>
    <input
      value=draft
      placeholder="Add an item"
      onChange={e => setDraft((e->JsxEvent.Form.target)["value"])}
    />
    <button onClick=addItem> {React.string("Add")} </button>
    <ul>
      {items
      ->List.toArray
      ->Array.mapWithIndex((item, i) =>
        <li key={Int.toString(i)}> {React.string(item)} </li>
      )
      ->React.array}
    </ul>
  </section>
}`

let staleClosureCode = `open Signals

let base = Signal.make(1)

@react.component
let make = () => {
  let (multiplier, setMultiplier) = React.useState(() => 2)

  // BUG: useComputed captures multiplier once (stale closure)
  let result = SignalsReact.useComputed(() =>
    Signal.get(base) * multiplier
  )

  // FIX: useComputedWithDeps recaptures on dep change
  let resultFixed = SignalsReact.useComputedWithDeps(
    () => Signal.get(base) * multiplier,
    multiplier,
  )

  // Try: increment multiplier, then increment base.
  // "stale" result uses the old multiplier value.
}`

let conditionalCode = `module Child = {
  @react.component
  let make = (~renderCount: Signal.t<int>) => {
    let (count, countSignal, _) =
      SignalsReact.useSignal(() => 0)

    React.useEffect0(() => {
      Signal.update(renderCount, n => n + 1)
      None
    })

    <div>
      <p> {React.string(\`Local: \${Int.toString(count)}\`)} </p>
      <button onClick={_ =>
        Signal.update(countSignal, n => n + 1)
      }>
        {React.string("Increment local")}
      </button>
    </div>
  }
}

// Toggle mounts/unmounts the child.
// useSignal stores the signal in a ref — it persists
// but is never disposed on unmount.`

let diamondCode = `open Signals

let root = Signal.make(1)
let left = Computed.make(() => Signal.get(root) * 2)
let right = Computed.make(() => Signal.get(root) * 3)

let recomputeCount = Signal.make(0)
let combined = Computed.make(() => {
  Signal.update(recomputeCount, n => n + 1)
  Signal.get(left) + Signal.get(right)
})

// When root changes, combined should recompute
// exactly once with consistent left & right values
// (no "glitch" with stale right + updated left).`

let rapidUpdateCode = `open Signals

let a = Signal.make(0)
let b = Signal.make(0)
let c = Signal.make(0)
let sum = Computed.make(() =>
  Signal.get(a) + Signal.get(b) + Signal.get(c)
)

let unbatched = _ => {
  Signal.update(a, n => n + 1) // re-render 1
  Signal.update(b, n => n + 1) // re-render 2
  Signal.update(c, n => n + 1) // re-render 3
}

let batched = _ => {
  Signal.batch(() => {
    Signal.update(a, n => n + 1)
    Signal.update(b, n => n + 1)
    Signal.update(c, n => n + 1)
  }) // single re-render
}`

@react.component
let make = () => {
  <main>
    <h1> {React.string("rescript-signals x rescript-react PoC")} </h1>
    <div className="demo-row">
      <Counter />
      {code(counterCode)}
    </div>
    <hr />
    <div className="demo-row">
      <DerivedDemo />
      {code(derivedCode)}
    </div>
    <hr />
    <div className="demo-row">
      <WriteDemo />
      {code(writeCode)}
    </div>
    <hr />
    <div className="demo-row">
      <StaleClosureDemo />
      {code(staleClosureCode)}
    </div>
    <hr />
    <div className="demo-row">
      <ConditionalDemo />
      {code(conditionalCode)}
    </div>
    <hr />
    <div className="demo-row">
      <DiamondDemo />
      {code(diamondCode)}
    </div>
    <hr />
    <div className="demo-row">
      <RapidUpdateDemo />
      {code(rapidUpdateCode)}
    </div>
  </main>
}
