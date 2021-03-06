import React from "react"
import { formatMoney, displayMoney } from "utils/text"
import { isIOS } from "utils/browser"
import { uniqueId } from "utils/id"
import classNames from "classnames"
const { func, string, number, bool } = React.PropTypes

export default React.createClass({
  propTypes: {
    onChange: func,
    className: string,
    name: string,
    value: number,
    defaultValue: number,
    id: string,
    isPositive: bool,
  },

  getDefaultProps() {
    return {
      defaultValue: 0,
      className: "",
    }
  },

  getInitialState() {
    const value = this.props.value || this.props.defaultValue

    return {
      value,
      visibleValue: formatMoney(value, false),
      isFocused: false,
      isPositive: value >= 0,
      id: this.props.id || uniqueId("money-input"),
    }
  },

  componentDidMount() {
    this.input.focus()
  },

  componentDidUpdate(_, prevState) {
    let needsNewVisibleValue = false
    let { value } = this.state

    if (prevState.value !== value) {
      this.props.onChange && this.props.onChange(value)
      this.input.focus()
    }

    if (this.getIsPositive(prevState) !== this.getIsPositive() &&
        prevState.value === value &&
        prevState.visibleValue === this.state.visibleValue) {
      value = value * -1
      this.setState({ value })
      this.input.focus()
      needsNewVisibleValue = true
    }

    if (!this.state.isFocused || needsNewVisibleValue) {
      const newVisibleValue = displayMoney(value, false)

      if (this.state.visibleValue !== newVisibleValue) {
        this.setState({ visibleValue: newVisibleValue })
      }
    }

  },

  handleChange({ target }) {
    if (isIOS) {
      const isPositive = this.getIsPositive()
      const rawCents = parseInt(target.value.replace(/\D/g, ""), 10) || 0
      const cents = rawCents * (isPositive ? 1 : -1)

      this.setState({ value: cents, visibleValue: displayMoney(cents, false) })
    } else {
      const newValue = Math.round(parseFloat(target.value.replace(/[^0-9\-\.]/g, "")) * 100) || 0

      this.setState({ value: newValue, visibleValue: target.value, isPositive: newValue >= 0 })
    }
  },

  handleFocus() {
    this.setState({ isFocused: true })
  },

  handleBlur() {
    this.setState({ isFocused: false })
  },

  getValue() {
    if (this.props.value) {
      return this.props.value
    } else {
      return this.state.value
    }
  },

  getIsPositive(state = this.state) {
    if (!isIOS || typeof this.props.isPositive === "undefined") {
      return state.isPositive
    } else {
      return this.props.isPositive
    }
  },

  render() {
    let { className, name, id, value, defaultValue, isPositive, ...rest } = this.props
    isPositive = this.getIsPositive()

    return (
      <div className={`${className} input-group money-input`}>
        <label
          htmlFor={id || this.state.id}
          className={classNames("input-group-badge input-group-badge--left", {
            "input-group-badge--danger": !isPositive,
            "input-group-badge--success": isPositive,
          })}
          >
          $
        </label>
        <input
          type="tel"
          pattern="[0-9\.\-,]*"
          id={id || this.state.id}
          {...rest}
          value={this.state.visibleValue}
          onChange={this.handleChange}
          onBlur={this.handleBlur}
          onFocus={this.handleFocus}
          ref={(e) => this.input = e}
          />
        <input type="hidden" name={name} value={this.getValue()} />
      </div>
    )
  },
})
