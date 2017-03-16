# Veelope

A super simple envelope budgeting tool built using Ruby on Rails + the Plaid API.

It's designed to be self-hosted, and stay out of your way. It uses [Plaid's transactions product](https://plaid.com/products/transactions/) to synchronize with your bank for maximum convenience.

## Setup

Get a [Plaid](https://plaid.com/) account, because you'll need those values to run the application. Then deploy to heroku!

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

### Non-Heroku

- Clone the repo
- Ensure all ENV variables in `.env.example` are set. `dotenv` is included, so you can copy that to `.env` and fill in the values to make it work
- `$ bundle`
- `$ bin/rake db:create && bin/rake db:migrate`
- `$ yarn` (or `npm install`)
- `$ foreman start`

## Help

Hit me up on Twitter [@personunsure](https://twitter.com/personunsure) or in the github issues if you need any help.

## Screenshots

Main screen

<img src="screenshots/home.png" alt="Home page" width="400" height="473" />

Transaction list

<img src="screenshots/transactions.png" alt="Home page" width="400" height="511" />

Transaction editor

<img src="screenshots/transaction-editor.png" alt="Home page" width="400" height="534" />

## Contributing

Pull requests and issues welcome!
