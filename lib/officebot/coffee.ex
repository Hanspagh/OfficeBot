defmodule Officebot.Coffee do
  require Logger
  use Slack

  @start_state %{:free => ["Anders", "Kristoffer", "Katrine", "Hans"], :used => []}

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    if mention_me?(message.text, slack.me.id) do
      case parse_message(message.text) do
        :hi ->send_message("Hello good sir!", message.channel, slack)
        {:ok, state}
        :none ->send_message("I didn't quite get that", message.channel, slack)
        {:ok, state}
        :made -> send_message(who_made_coffee_already(state), message.channel, slack)
        {:ok, state}
        :reset ->new_state = reset(message.channel, slack)
        {:ok, new_state}
        :coffee -> send_message("Lets see...", message.channel, slack)
        send_message(who_made_coffee_already(state), message.channel, slack)
        new_state = check_state(state, message.channel, slack)
        send_message("Soooooooo I pick.....", message.channel, slack)
        send_message("Give me a sec, I wil go ask my manager.....", message.channel, slack)
        send_message("I pick.....", message.channel, slack)
        person = pick_random_person(new_state)
        send_message(person, message.channel, slack)
        {:ok, update_state(new_state,person)}
      end
    else
      {:ok, state}
    end
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp check_state(%{free: free}, channel, slack) when length(free) == 0  do
    reset(channel, slack)
  end

  defp check_state(state, _channel, _slack) do
    state
  end

  defp reset(channel, slack) do
    send_message("I have reset", channel, slack)
    @start_state
  end

  defp pick_random_person(%{free: free}) do
    Enum.random(free)
  end

  defp update_state(%{free: free, used: used}, person) do
    free = List.delete(free, person)
    used = used ++ [person]
    %{free: free, used: used}
  end


  defp who_made_coffee_already(%{free: free}) when length(free) == 0  do
    "Everybody made coffee today, Let me reset"
  end

  defp who_made_coffee_already(%{used: used}) when length(used) == 0  do
    "Nobody made coffee today"
  end

  defp who_made_coffee_already(%{used: used}) do

    case length(used) do
      1 -> List.first(used) <> " already made coffee today, Yay"
      _ ->
      fst_person = List.first(used)
      remaining = List.delete(used, fst_person)
      persons = Enum.join(remaining, ", ")
      persons <> " & " <> fst_person <> " already made coffee today, Yay"
    end
  end

  defp mention_me?(message, my_id) do
    message =~ ~r/^.*<@#{my_id}>:?.*$/ || message =~ ~r/^.*office.*$/ || message =~ ~r/^.*bot.*$/
  end

  defp parse_message(message) do
    cond do
      message =~ ~r/^.*made.*$/i -> :made
      message =~ ~r/^.*hi.*$/i -> :hi
      message =~ ~r/^.*coffee.*$/i -> :coffee
      message =~ ~r/^.*kaffe.*$/i -> :coffee
      message =~ ~r/^.*reset.*$/i -> :reset
      true -> :none
    end

  end

end
#HTTPoison.start
#Slack.Bot.start_link(Officebot.Coffee, [], "xoxb-110725207491-e9cvEXlnZIV8L1jwvMbhWYuc")