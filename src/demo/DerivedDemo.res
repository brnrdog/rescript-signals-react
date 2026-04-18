open Signals

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
    <p> {React.string(`Full name: ${fullName}`)} </p>
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
}
