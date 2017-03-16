import React from "react"
import { displayMoney } from "utils/text"
import DesignationEditor from "components/designation_editor"
const { number, array } = React.PropTypes

export default React.createClass({
  propTypes: {
    fromEnvelopeId: number.isRequired,
    availableBalanceCents: number.isRequired,
    envelopes: array.isRequired,
    designations: array.isRequired,
  },

  render() {
    return (
      <div>
        <div className="mb-1r">Available amount: {displayMoney(this.props.availableBalanceCents)}</div>

        <DesignationEditor
          isNewRecord={true}
          envelopes={this.props.envelopes}
          limitCents={this.props.availableBalanceCents}
          initialDesignations={this.props.designations}
          name="funding"
          />
      </div>
    )
  },
})
