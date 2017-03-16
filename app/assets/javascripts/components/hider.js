import React from "react"
const { bool, node, string } = React.PropTypes

export default React.createClass({
  propTypes: {
    defaultVisible: bool,
    visible: bool,
    children: node,
    toggle: string,
  },

  getDefaultProps() {
    return {
      defaultVisible: true,
      toggle: "Toggle",
    }
  },

  getInitialState() {
    return {
      visible: this.props.defaultVisible,
      hasBecomeVisible: this.props.defaultVisible,
    }
  },

  handleToggle() {
    this.setState({ visible: !this.state.visible, hasBecomeVisible: true })
  },

  getVisible() {
    if (this.props.hasOwnProperty("visible")) {
      return this.props.visible
    } else {
      return this.state.visible
    }
  },

  getStyle() {
    if (this.getVisible()) {
      return { }
    } else {
      return { display: "none" }
    }
  },

  render() {
    const { defaultVisible, visible, children, toggle, ...rest } = this.props

    return (
      <div {...rest}>
        {this.state.hasBecomeVisible && (
          <div style={this.getStyle()}>
            {this.props.children}
          </div>
        )}

        <a onClick={this.handleToggle} className="btn">{this.props.toggle}</a>
      </div>
    )
  },
})
