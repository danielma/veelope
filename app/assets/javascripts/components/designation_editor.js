import React from "react"
import { prop, sum } from "ramda"
import { displayMoney } from "utils/text"
const { arrayOf, shape, string, number, bool } = React.PropTypes
import MoneyInput from "components/money_input"

function emptyDesignation(overrides = {}) {
  return {
    amountCents: 0,
    ...overrides,
  }
}

export default React.createClass({
  propTypes: {
    totalAmountCents: number,
    isNewRecord: bool.isRequired,
    envelopes: arrayOf(shape({
      name: string.isRequired,
      fullName: string.isRequired,
      id: number.isRequired,
    })).isRequired,
    initialDesignations: arrayOf(shape({
      id: number,
      envelopeId: number.isRequired,
      amountCents: number.isRequired,
    })),
    limitCents: number,
    name: string,
  },

  getDefaultProps() {
    return {
      initialDesignations: [],
      name: "bank_transaction",
    }
  },

  getInitialState() {
    return {
      designations: this.getInitialDesignations(),
    }
  },

  handleAddClick() {
    const envelopeId = this.getAvailableEnvelopeIds()[0]

    this.setState({
      designations: this.state.designations.concat(emptyDesignation({ envelopeId })),
    })
  },

  handleKeyDown(e) {
    if (e.ctrlKey && e.key === "s") {
      this.handleAddClick()
    }
  },

  handleUpdateDesignation(index, designation) {
    const newDesignations = [...this.state.designations]
    newDesignations.splice(index, 1, designation)
    this.setState({ designations: newDesignations })
  },

  handleRemoveDesignation(index) {
    const newDesignations = [...this.state.designations]
    newDesignations.splice(index, 1)
    this.setState({ designations: newDesignations })
  },

  getAvailableEnvelopeIds() {
    const usedEnvelopes = this.state.designations.map(prop("envelopeId"))
    return this.props.envelopes.filter(({ id }) => !usedEnvelopes.includes(id)).map(prop("id"))
  },

  getInitialDesignations() {
    const { initialDesignations, totalAmountCents, envelopes } = this.props

    if (initialDesignations.length > 0) {
      return initialDesignations
    } else {
      return [emptyDesignation({ amountCents: totalAmountCents || 0, envelopeId: envelopes[0].id })]
    }
  },

  render() {
    const { envelopes, totalAmountCents, isNewRecord, limitCents } = this.props
    const { designations } = this.state
    const totalCents = sum(designations.map(prop("amountCents")))
    const isPositive = totalAmountCents > 0

    return (
      <div onKeyDown={this.handleKeyDown}>
        {designations.map((designation, index) => (
          <Designation
            key={designation.id ? `d${designation.id}` : `e${designation.envelopeId}${index}`}
            context={this.props.name}
            designation={designation}
            envelopes={envelopes}
            availableEnvelopeIds={this.getAvailableEnvelopeIds()}
            onUpdate={(d) => this.handleUpdateDesignation(index, d)}
            onRemove={designations.length > 1 ? () => this.handleRemoveDesignation(index) : null}
            isPositive={isPositive}
            index={index} />
        ))}

        <div>
          <button onClick={this.handleAddClick} className="btn" type="button">Split</button>
          <span className="mx-1r">Total: {displayMoney(totalCents)}</span>
          {!isNewRecord && (
            totalCents !== totalAmountCents ? (
              <small className="c-red">Off by {displayMoney(totalCents - totalAmountCents)}</small>
            ) : (
              <small className="c-green"><i className="fa fa-check" /></small>
            )
          )}
          {limitCents && totalCents > limitCents && (
            <small className="c-red">Over by {displayMoney(totalCents - limitCents)}</small>
          )}
        </div>

        {isNewRecord &&
          <input name="bank_transaction[amount_cents]" type="hidden" value={totalCents} />
        }
      </div>
    )
  },
})

function Designation({
  designation,
  index,
  envelopes,
  availableEnvelopeIds,
  onUpdate,
  onRemove,
  context,
  isPositive,
}) {
  function name(inputName) {
    return `${context}[designations_attributes][${index}][${inputName}]`
  }

  function handleChangeEnvelopeId({ target }) {
    onUpdate({ ...designation, envelopeId: parseInt(target.value, 10) })
  }

  function handleChangeAmount(amountCents) {
    onUpdate({ ...designation, amountCents })
  }

  const usableEnvelopes = envelopes.filter((e) => {
    return e.id === designation.envelopeId || availableEnvelopeIds.includes(e.id)
  })

  return (
    <div className="d-f mb-1r">
      <div className="f-1@!sm">
        <MoneyInput
          className="mr-05r@sm"
          name={name("amount_cents")}
          value={designation.amountCents}
          isPositive={isPositive}
          onChange={handleChangeAmount} />
        <select
          name={name("envelope_id")}
          defaultValue={designation.envelopeId}
          onChange={handleChangeEnvelopeId}
          className="w-100% w-a@sm mt-025r@!sm">
          {usableEnvelopes.map((envelope) => (
            <option key={envelope.fullName} value={envelope.id}>{envelope.fullName}</option>
          ))}
        </select>
      </div>

      {onRemove && (
        <button
          onClick={onRemove}
          className="btn ml-025r btn--sm btn--symbol btn--secondary"
          type="button"
          >
          &times;
        </button>
      )}
    </div>
  )
}
