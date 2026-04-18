open Signals

module Child = {
  @react.component
  let make = (~renderCount: Signal.t<int>) => {
    let (count, countSignal, _) = SignalsReact.useSignal(() => 0)

    // Track renders via a signal effect — bumps on every React render
    React.useEffect0(() => {
      Signal.update(renderCount, n => n + 1)
      None
    })

    <div style={{padding: "1rem", border: "1px solid #ccc", borderRadius: "4px"}}>
      <p> {React.string(`Local signal count: ${Int.toString(count)}`)} </p>
      <button onClick={_ => Signal.update(countSignal, n => n + 1)}>
        {React.string("Increment local")}
      </button>
    </div>
  }
}

@react.component
let make = () => {
  let (show, setShow) = React.useState(() => true)
  let renderCountSignal = React.useRef(Signal.make(0))
  let renderCount = SignalsReact.useSignalValue(renderCountSignal.current)

  <section>
    <h2> {React.string("Conditional mount / unmount")} </h2>
    <p> {React.string(`Child render count: ${Int.toString(renderCount)}`)} </p>
    <button onClick={_ => setShow(prev => !prev)}>
      {React.string(show ? "Unmount child" : "Mount child")}
    </button>
    <button onClick={_ => Signal.set(renderCountSignal.current, 0)}>
      {React.string("Reset counter")}
    </button>
    {show ? <Child renderCount={renderCountSignal.current} /> : React.null}
  </section>
}
