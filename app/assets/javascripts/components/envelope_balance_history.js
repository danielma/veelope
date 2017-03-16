import React from "react"
import Hider from "components/hider"
import moment from "moment"
import { timeFormat } from "d3-time-format"
import { displayMoney } from "utils/text"
import {
  ResponsiveContainer,
  LineChart,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Line,
} from "recharts"

const dateFormat = timeFormat("%m/%d")

export default function EnvelopeBalanceHistory({ initialBalanceCents, designations }) {
  const initialBalance = {
    amountCents: initialBalanceCents,
    postedAt: moment(designations[0].postedAt).subtract(1, "days").valueOf(),
  }

  const balanceOverTime = designations.reduce((acc, designation) => {
    const previousDesignation = acc[acc.length - 1] || { amountCents: 0 }

    return acc.concat([{
      amountCents: designation.amountCents + previousDesignation.amountCents,
      postedAt: new Date(designation.postedAt).valueOf(),
    }])
  }, [initialBalance])

  function formatTick(epoch) {
    const date = new Date()
    date.setTime(epoch)
    return dateFormat(date)
  }

  return (
    <Hider
      defaultVisible={false}
      toggle="Show Chart"
      className="my-1r">
      <ResponsiveContainer width="100%" height={250}>
        <LineChart
          data={balanceOverTime}
          margin={{ top: 5, right: 5, left: 5, bottom: 5 }}
          >
          <XAxis
            type="number"
            dataKey="postedAt"
            tickFormatter={formatTick}
            padding={{ left: 20, right: 20 }}
            domain={["auto", "auto"]} />
          <YAxis
            padding={{ bottom: 10, top: 10 }}
            domain={["auto", "auto"]}
            tickFormatter={displayMoney} />
          <CartesianGrid
            vertical={false}
            strokeDasharray="3" />
          <Tooltip
            formatter={(v) => displayMoney(v)}
            labelFormatter={formatTick} />
          <Line
            type="monotone"
            name="Balance"
            animationDuration={0}
            dataKey="amountCents"
            stroke="#8884d8" />
        </LineChart>
      </ResponsiveContainer>
    </Hider>
  )
}
