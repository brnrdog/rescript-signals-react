open Signals

let a = Signal.make(0)
let b = Signal.make(0)
let c = Signal.make(0)

let renderCount = Signal.make(0)

let sum = Computed.make(() => Signal.get(a) + Signal.get(b) + Signal.get(c))

@react.component
let make = () => {
  let aVal = SignalsReact.useSignalValue(a)
  let bVal = SignalsReact.useSignalValue(b)
  let cVal = SignalsReact.useSignalValue(c)
  let sumVal = SignalsReact.useSignalValue(sum)
  let renders = SignalsReact.useSignalValue(renderCount)

  React.useEffect0(() => {
    Signal.update(renderCount, n => n + 1)
    None
  })

  let unbatched = _ => {
    Signal.update(a, n => n + 1)
    Signal.update(b, n => n + 1)
    Signal.update(c, n => n + 1)
  }

  let batched = _ => {
    Signal.batch(() => {
      Signal.update(a, n => n + 1)
      Signal.update(b, n => n + 1)
      Signal.update(c, n => n + 1)
    })
  }

  let reset = _ => {
    Signal.batch(() => {
      Signal.set(a, 0)
      Signal.set(b, 0)
      Signal.set(c, 0)
      Signal.set(renderCount, 0)
    })
  }

  <section>
    <h2> {React.string("Rapid unbatched vs batched updates")} </h2>
    <p> {React.string(`a = ${Int.toString(aVal)}, b = ${Int.toString(bVal)}, c = ${Int.toString(cVal)}`)} </p>
    <p> {React.string(`sum (a + b + c) = ${Int.toString(sumVal)}`)} </p>
    <p>
      <strong> {React.string(`Render count: ${Int.toString(renders)}`)} </strong>
    </p>
    <div>
      <button onClick=unbatched>
        {React.string("Unbatched +1 each")}
      </button>
      <button onClick=batched>
        {React.string("Batched +1 each")}
      </button>
      <button onClick=reset>
        {React.string("Reset")}
      </button>
    </div>
  </section>
}
