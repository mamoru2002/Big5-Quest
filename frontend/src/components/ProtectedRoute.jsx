import { Navigate, Outlet } from 'react-router-dom'
import { getAuthToken } from '../lib/api'

export default function ProtectedRoute() {
  const authed = Boolean(getAuthToken())
  return authed ? <Outlet /> : <Navigate to="/signin" replace />
}