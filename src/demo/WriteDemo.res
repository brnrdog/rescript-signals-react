open Signals

type item = {id: int, text: string}

let nextId = ref(0)

let makeItem = text => {
  nextId := nextId.contents + 1
  {id: nextId.contents, text}
}

@react.component
let make = () => {
  let (items, itemsSignal, _) = SignalsReact.useSignal(() => [])
  let (draft, _, setDraft) = SignalsReact.useSignal(() => "")

  let addItem = _ => {
    let trimmed = String.trim(draft)
    if trimmed != "" {
      Signal.batch(() => {
        Signal.update(itemsSignal, xs => Array.concat([makeItem(trimmed)], xs))
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
      ->Array.map(({id, text}) =>
        <li key={Int.toString(id)}> {React.string(text)} </li>
      )
      ->React.array}
    </ul>
  </section>
}
