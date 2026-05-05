import { NavLink, Route, Routes } from 'react-router-dom'

const destinations = [
  { label: 'Home', path: '/', end: true },
  { label: 'Made', path: '/made' },
  { label: 'Found', path: '/found' },
  { label: 'Timeline', path: '/timeline' },
  { label: 'Add Memory', path: '/add' },
]

function Placeholder({
  title,
  description,
}: {
  title: string
  description: string
}) {
  return (
    <section className="placeholder" aria-labelledby={`${title}-heading`}>
      <p className="eyebrow">FoodLife</p>
      <h1 id={`${title}-heading`}>{title}</h1>
      <p>{description}</p>
    </section>
  )
}

function App() {
  return (
    <div className="app-shell">
      <header className="topbar">
        <a className="brand" href="/">
          FoodLife
        </a>
        <nav aria-label="Primary destinations">
          {destinations.map((destination) => (
            <NavLink
              key={destination.path}
              to={destination.path}
              end={destination.end}
              className={({ isActive }) =>
                isActive ? 'nav-link active' : 'nav-link'
              }
            >
              {destination.label}
            </NavLink>
          ))}
        </nav>
      </header>

      <main>
        <Routes>
          <Route
            path="/"
            element={
              <Placeholder
                title="Home"
                description="A local-first starting point for recent meals, seasonal memories, and the next FoodLife destination."
              />
            }
          />
          <Route
            path="/made"
            element={
              <Placeholder
                title="Made"
                description="Food you cooked, saved as a personal archive of meals, context, and memory."
              />
            }
          />
          <Route
            path="/found"
            element={
              <Placeholder
                title="Found"
                description="Food and places discovered outside, kept separate from meals made at home."
              />
            }
          />
          <Route
            path="/timeline"
            element={
              <Placeholder
                title="Timeline"
                description="A chronological view for browsing FoodLife memories across Made and Found."
              />
            }
          />
          <Route
            path="/add"
            element={
              <Placeholder
                title="Add Memory"
                description="A future entry point for capturing a Made or Found food memory."
              />
            }
          />
          <Route
            path="/memories/:memoryId"
            element={
              <Placeholder
                title="Detail View"
                description="A future detail placeholder for one local FoodLife memory."
              />
            }
          />
          <Route
            path="/memories/:memoryId/edit"
            element={
              <Placeholder
                title="Edit Memory"
                description="A future edit placeholder for updating a local FoodLife memory."
              />
            }
          />
        </Routes>

        <div className="split-summary" aria-label="Made and Found summary">
          <div>
            <strong>Made</strong>
            <span>Food you cooked</span>
          </div>
          <div>
            <strong>Found</strong>
            <span>Food and places discovered outside</span>
          </div>
        </div>
      </main>
    </div>
  )
}

export default App
