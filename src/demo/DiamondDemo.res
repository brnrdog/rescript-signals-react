open Signals

let root = Signal.make(1)

// Diamond: root -> left, root -> right, (left, right) -> combined
let left = Computed.make(() => Signal.get(root) * 2)
let right = Computed.make(() => Signal.get(root) * 3)

let recomputeCount = Signal.make(0)
let combined = Computed.make(() => {
  Signal.update(recomputeCount, n => n + 1)
  Signal.get(left) + Signal.get(right)
})

@react.component
let make = () => {
  let rootVal = SignalsReact.useSignalValue(root)
  let leftVal = SignalsReact.useSignalValue(left)
  let rightVal = SignalsReact.useSignalValue(right)
  let combinedVal = SignalsReact.useSignalValue(combined)
  let recomputes = SignalsReact.useSignalValue(recomputeCount)

  <section>
    <h2> {React.string("Diamond dependency graph")} </h2>
    <p> {React.string(`root = ${Int.toString(rootVal)}`)} </p>
    <p> {React.string(`left (root × 2) = ${Int.toString(leftVal)}`)} </p>
    <p> {React.string(`right (root × 3) = ${Int.toString(rightVal)}`)} </p>
    <p>
      <strong> {React.string(`combined (left + right) = ${Int.toString(combinedVal)}`)} </strong>
    </p>
    <p> {React.string(`Combined recompute count: ${Int.toString(recomputes)}`)} </p>
    <div>
      <button onClick={_ => Signal.update(root, n => n + 1)}>
        {React.string("Increment root")}
      </button>
      <button onClick={_ => {
        Signal.set(root, 1)
        Signal.set(recomputeCount, 0)
      }}>
        {React.string("Reset")}
      </button>
    </div>
  </section>
}
