defmodule Officebot.Coffee do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    if mention_me?(message.text, slack.me.id) do
      case parse_message(message.text) do
        :coffee -> send_message("Jonas go make coffee", message.channel, slack)
        :hi -> send_message("Hello good sir!", message.channel, slack)
        :none -> send_message("I didnt get that", message.channel, slack)
      end
    end

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}


  defp mention_me?(message, my_id) do
    message =~ ~r/^.*<@#{my_id}>:?.*$/ || message =~ ~r/^.*office.*$/ || message =~ ~r/^.*bot.*$/
  end

  defp parse_message(message) do
    cond do
      message =~ ~r/^.*hi.*$/ -> :hi
      message =~ ~r/^.*coffee.*$/ -> :coffee
      message =~ ~r/^.*kaffe.*$/ -> :coffee
      true -> :none
    end

  end

end
#HTTPoison.start
#Slack.Bot.start_link(Officebot.Coffee, [], "xoxb-110725207491-e9cvEXlnZIV8L1jwvMbhWYuc")
