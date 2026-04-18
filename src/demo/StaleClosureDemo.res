open Signals

// Module-level signal for the base value
let base = Signal.make(1)

@react.component
let make = () => {
  let (multiplier, setMultiplier) = React.useState(() => 2)

  // BUG: useComputed uses useMemo0 — the closure captures `multiplier` once
  // and never updates when React state changes.
  let result = SignalsReact.useComputed(() => Signal.get(base) * multiplier)

  // FIX: useComputedWithDeps recaptures the closure when deps change.
  let resultFixed = SignalsReact.useComputedWithDeps(
    () => Signal.get(base) * multiplier,
    multiplier,
  )

  let baseValue = SignalsReact.useSignalValue(base)

  <section>
    <h2> {React.string("Stale closure in useComputed")} </h2>
    <p>
      {React.string(`Base signal: ${Int.toString(baseValue)}`)}
    </p>
    <p>
      {React.string(`Multiplier (React state): ${Int.toString(multiplier)}`)}
    </p>
    <p>
      <strong> {React.string("useComputed (stale): ")} </strong>
      {React.string(`${Int.toString(baseValue)} × ${Int.toString(multiplier)} = ${Int.toString(result)}`)}
    </p>
    <p>
      <strong> {React.string("useComputedWithDeps (correct): ")} </strong>
      {React.string(`${Int.toString(baseValue)} × ${Int.toString(multiplier)} = ${Int.toString(resultFixed)}`)}
    </p>
    <div>
      <button onClick={_ => Signal.update(base, n => n + 1)}>
        {React.string("Increment base")}
      </button>
      <button onClick={_ => setMultiplier(prev => prev + 1)}>
        {React.string("Increment multiplier")}
      </button>
      <button onClick={_ => {
        Signal.set(base, 1)
        setMultiplier(_ => 2)
      }}>
        {React.string("Reset")}
      </button>
    </div>
  </section>
}
