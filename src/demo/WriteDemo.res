open Signals

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
    <h2> {React.string("Write / update flow (component-local signals)")} </h2>
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
}
