import { cleanup, render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'
import App from './App'

const renderRoute = (route: string) =>
  render(
    <MemoryRouter initialEntries={[route]}>
      <App />
    </MemoryRouter>,
  )

describe('FoodLife app shell', () => {
  it('renders the primary FoodLife destinations from the home route', () => {
    renderRoute('/')

    expect(screen.getByRole('heading', { name: 'Home' })).toBeInTheDocument()

    for (const destination of [
      'Home',
      'Made',
      'Found',
      'Timeline',
      'Add Memory',
    ]) {
      expect(screen.getByRole('link', { name: destination })).toBeInTheDocument()
    }

    expect(screen.getByText(/food you cooked/i)).toBeInTheDocument()
    expect(screen.getByText(/places discovered outside/i)).toBeInTheDocument()
  })

  it('renders detail and edit placeholders for memory routes', () => {
    renderRoute('/memories/demo-memory')

    expect(
      screen.getByRole('heading', { name: 'Detail View' }),
    ).toBeInTheDocument()

    cleanup()
    renderRoute('/memories/demo-memory/edit')

    expect(screen.getByRole('heading', { name: 'Edit Memory' })).toBeInTheDocument()
  })
})
