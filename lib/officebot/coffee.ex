defmodule Officebot.Coffee do
  require Logger
  use Slack

  @start_state %{:free => ["Anders", "Kristoffer", "Jonas", "Katrine", "Hans"], :used => []}



  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    #IO.puts slack.channels
    #Logger.debug(slack.channels)
    send_message("༼ つ ◕_◕ ༽つ OfficeBot is here to save the day", "#coffee-and-bots", slack)
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    if mention_me?(message.text, slack.me.id) do
      case parse_message(message.text) do
        :jul -> send_message("༼ つ ◕_◕ ༽つ由 Merry Christmas everybody! :christmas_tree:", message.channel, slack)
        {:ok, state}
        :table -> send_message("༼ づ ◉ Д ◉ ༽づ彡┻━━━━━┻", message.channel, slack)
        {:ok, state}
        {:exclude, person} ->
          case update_state(state,person) do
            {:ok, new_state} -> send_message("It seems like #{person} already made coffee today", message.channel, slack)
            {:ok, new_state}
            {:error, error_message} -> send_message(error_message, message.channel, slack)
            {:ok, state}
          end
          :love -> send_message("༼ つ ◕‿◕ ༽つ Stop it, you are being too sweet", message.channel, slack)
          {:ok, state}
          :openhouse -> send_message(get_open_house_rating(), message.channel, slack)
          {:ok, state}
          :joke -> send_message(get_joke(), message.channel, slack)
          {:ok, state}
          :hi -> send_message("༼ つ ◕_◕ ༽つ Hello good sir!", message.channel, slack)
          {:ok, state}
          :none ->send_message("༼ つ ◕_◕ ༽つ I didn't quite get that", message.channel, slack)
          {:ok, state}
          :made -> send_message(who_made_coffee_already(state), message.channel, slack)
          {:ok, state}
          :reset ->new_state = reset(message.channel, slack)
          {:ok, new_state}
          :coffee -> send_message("༼ つ ◕_◕ ༽つ Lets see...", message.channel, slack)
          send_message(who_made_coffee_already(state), message.channel, slack)
          new_state = check_state(state, message.channel, slack)
          send_message("Soooooooo who is it gonna be????", message.channel, slack)
          send_message("Give me a sec, I will go ask my manager.....", message.channel, slack)
          send_message("I pick.....", message.channel, slack)
          person = pick_random_person(new_state)
          send_message(person, message.channel, slack)
          {:ok, update_state(new_state,person)}
        end
      else
        Logger.debug(message.text)
        {:ok, state}
      end
    end

    def handle_event(_, _, state), do: {:ok, state}


    defp get_open_house_rating() do
      with {:ok, response} <- HTTPoison.get("https://itunes.apple.com/search?term=openhouse%20by%20sunday&country=dk&entity=software"),
      {:ok, json} <- JSX.decode response.body do
        app = List.first json["results"]
        "OpenHouse's current avg. rating is #{app["averageUserRating"]}, rated by #{app["userRatingCount"]} people"
      else
        :error -> "Woops, Something went wrong"
      end


    end

    defp get_joke() do

      with {:ok, response} <- HTTPoison.get("http://tambal.azurewebsites.net/joke/random"),
      {:ok, json} <- JSX.decode response.body do
        json["joke"]
      else
        :error -> "Woops, Something went wrong"
      end

    end

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
      if(Enum.member?(free, person)) do
        free = List.delete(free, person)
        used = used ++ [person]
        %{free: free, used: used}
      else
        {:error, "The person dosn't exists"}
      end
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
      message =~ ~r/^.*<@#{my_id}>:?.*$/ || message =~ ~r/^.*office.*$/ || message =~ ~r/^.*bot.*$/i
    end

    defp parse_message(message) do
      cond do
        message =~ ~r/^.*christmas.*$/i -> :jul
        message =~ ~r/^.*mad.*$/i -> :table
        message =~ ~r/.*exclude ([a-z]*).*$/i ->
          res = Regex.run(~r/.*exclude ([a-z]*).*$/i, message)
          {:exclude, Enum.at(res, 1)}
          message =~ ~r/^.*made.*$/i -> :made
          message =~ ~r/^.*love.*$/i -> :love
          message =~ ~r/^.*openhouse.*$/i -> :openhouse
          message =~ ~r/^.*coffee.*$/i -> :coffee
          message =~ ~r/^.*kaffe.*$/i -> :coffee
          message =~ ~r/^.*reset.*$/i -> :reset
          message =~ ~r/^.*joke.*$/i -> :joke
          message =~ ~r/^.*hi.*$/i -> :hi
          true -> :none
        end

      end

    end
    #HTTPoison.start
    #Slack.Bot.start_link(Officebot.Coffee, [], "xoxb-110725207491-e9cvEXlnZIV8L1jwvMbhWYuc")
