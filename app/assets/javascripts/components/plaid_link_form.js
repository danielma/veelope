import React from "react"
import { initPlaid } from "plaid"
import { FormTag } from "react-rails-form-helpers"
const { string } = React.PropTypes

export default class PlaidLinkForm extends React.Component {
  static propTypes = {
    url: string.isRequired,
    existingPublicToken: string
  };

  static defaultProps = {
    publicToken: null
  };

  state = {
    plaidPublicToken: ""
  };

  componentDidMount() {
    const plaidOptions = { onSuccess: this.handleLinkSuccess }

    if (this.props.existingPublicToken) {
      plaidOptions.token = this.props.existingPublicToken
    }

    this.plaidLink = initPlaid(plaidOptions)

    // onLoad: // The Link module finished loading.
    // onExit: // The user exited the Link flow.
  }

  handleLinkClick = () => {
    this.plaidLink.open()
  };

  handleLinkSuccess = (publicToken, _metadata) => {
    this.setState({ plaidPublicToken: publicToken }, () => {
      this.publicTokenInput.form.submit()
    })
  };

  render() {
    const method = this.props.existingPublicToken ? "patch" : "post"
    return (
      <div>
        <FormTag url={this.props.url} method={method}>
          <input
            ref={i => (this.publicTokenInput = i)}
            type="hidden"
            name="public_token"
            value={this.state.plaidPublicToken}
          />
        </FormTag>
        <button className="btn btn--primary" onClick={this.handleLinkClick}>
          Link to Plaid
        </button>
      </div>
    )
  }
}
