import React from "react"
const { arrayOf, string, number } = React.PropTypes

export default React.createClass({
  propTypes: {
    notifications: arrayOf(string),
    hideAfterSeconds: number,
  },

  getDefaultProps() {
    return {
      notifications: [],
      hideAfterSeconds: 3,
    }
  },

  getInitialState() {
    return {
      isVisible: true,
    }
  },

  componentDidMount() {
    setTimeout(this.handleHide, this.props.hideAfterSeconds * 1000)
  },

  handleHide() {
    this.setState({ isVisible: false })
  },

  render() {
    const { notifications } = this.props

    if (notifications.length === 0) { return null }

    return (
      <div className={this.state.isVisible ? "o" : "o.0"}>
        <span className="c-green">
          <i className="fa fa-check" />
          &nbsp;
        </span>
        <span className="c-white">
          {notifications.map((notification) => (
            <span key={notification}>{notification}</span>
          ))}
        </span>
      </div>
    )
  },
})
