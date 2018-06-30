import React from "react"
import bankTransactionApi from "api/bank_transaction"
const { arrayOf, shape, string, number, bool } = React.PropTypes

export default React.createClass({
  propTypes: {
    bankTransaction: shape({
      id: number.isRequired,
      amountCents: number.isRequired,
      envelopes: arrayOf(shape({
        name: string.isRequired,
      })),
    }).isRequired,
    envelopes: arrayOf(shape({
      name: string.isRequired,
      fullName: string.isRequired,
      id: number.isRequired,
    })).isRequired,
    disabled: bool,
  },

  getInitialState() {
    return {
      updated: false,
    }
  },

  handleChange({ target }) {
    const { bankTransaction } = this.props
    const params = {
      designations_attributes: [
        { envelope_id: target.value, amount_cents: bankTransaction.amountCents },
      ],
    }

    bankTransactionApi.update(bankTransaction.id, params).
      then(this.handleUpdated)
  },

  handleUpdated() {
    this.setState({ updated: true })
    setTimeout(() => this.setState({ updated: false }), 1000)
  },

  render() {
    const { envelopes, bankTransaction, disabled } = this.props
    const envelope = bankTransaction.envelopes[0]

    return (
      <div>
        {bankTransaction.envelopes.length > 1 ? (
          <span>Split</span>
        ) : disabled ? (
          <span>{envelope ? envelope.fullName : "No designations"}</span>
        ) : (
          <div className="designation-selector">
            <select
              className="d-b"
              onChange={this.handleChange}
              defaultValue={envelope && envelope.id}
              >
              <option>(None)</option>
              {envelopes.map((e) => (
                <option key={e.id} value={e.id}>{e.fullName}</option>
              ))}
            </select>
            <div className="c-green designation-selector-update-indicator">
              <i className="fa fa-check" style={{ opacity: this.state.updated ? 1 : 0 }} />
            </div>
          </div>
        )}
      </div>
    )
  },
})
