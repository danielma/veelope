import React from "react"
import ReactDOM from "react-dom"
import NotificationsContainer from "components/notifications_container"
import dataToggleSiblings from "data_actions/toggle_siblings"

export default function(config) {
  if (config.refreshing_connections) {
    notifyRefreshingConnections(config.refreshing_connections.map((connection) => (
      `Refreshing ${connection}. Things will be updated shortly`
    )))
  }

  dataToggleSiblings.attach()
}

function notifyRefreshingConnections(notifications = []) {
  const notificationsContainer = document.getElementById("notifications-container")

  ReactDOM.render(<NotificationsContainer notifications={notifications} />, notificationsContainer)
}

