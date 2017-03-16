export function capitalize(str) {
  return `${str[0].toUpperCase()}${str.slice(1)}`
}

export function camelCase(str) {
  return str.
    split(/[^a-zA-Z0-9]/).
    reduce((a, e) => {
      return a + capitalize(e)
    })
}

export function displayMoney(amountCents, includeCurrencySign = true) {
  if (includeCurrencySign) {
    return (amountCents / 100).
      toLocaleString("en-US", { currency: "USD", style: "currency" })
  } else {
    return (amountCents / 100).
      toLocaleString("en-US", {
        style: "decimal",
        maximumFractionDigits: 2,
        minimumFractionDigits: 2,
      })
  }
}

export function formatMoney(amountCents, includeCurrencySign = true) {
  const formatted = (amountCents / 100).toFixed(2)

  if (includeCurrencySign) {
    return `$${formatted}`
  } else {
    return formatted
  }
}
