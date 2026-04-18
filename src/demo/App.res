@react.component
let make = () => {
  <main>
    <h1> {React.string("rescript-signals x rescript-react PoC")} </h1>
    <Counter />
    <hr />
    <DerivedDemo />
    <hr />
    <WriteDemo />
  </main>
}
