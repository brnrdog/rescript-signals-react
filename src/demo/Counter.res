open Signals

let countSignal = Signal.make(0)

@react.component
let make = () => {
  let count = SignalsReact.useSignalValue(countSignal)

  <section>
    <h2> {React.string("Basic signal")} </h2>
    <p> {React.string(`Count: ${Int.toString(count)}`)} </p>
    <button onClick={_ => Signal.update(countSignal, c => c + 1)}>
      {React.string("Increment")}
    </button>
    <button onClick={_ => Signal.set(countSignal, 0)}>
      {React.string("Reset")}
    </button>
  </section>
}
