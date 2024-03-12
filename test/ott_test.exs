defmodule OTTTest do
  use ExUnit.Case, async: true
  use OTT.DataCase

  alias OTT.OneTimeTokens.OneTimeToken

  describe "generate_token/2" do
    test "when data is valid, it generates a token" do
      utc_now = DateTime.utc_now()
      token = OTT.generate_token!(%{key: :value})

      assert [%OneTimeToken{token: ^token} = one_time_token] = OneTimeToken |> OTT.repo().all()

      assert one_time_token.data == %{"key" => "value"}

      assert_in_delta DateTime.to_unix(one_time_token.expired_at),
                      utc_now
                      |> DateTime.add(OTT.default_expires_in_minutes(), :minute)
                      |> DateTime.to_unix(),
                      5

      assert one_time_token.lock_version == 1
      assert is_nil(one_time_token.revoked_at)
      assert is_nil(one_time_token.scope)
      assert String.length(token) == OTT.default_token_length()
      assert one_time_token.token == token
      assert is_nil(one_time_token.used_at)
    end

    test "token_length can be overrided" do
      token = OTT.generate_token!(%{key: :value}, token_length: 5)
      assert String.length(token) == 5
    end

    test "when token_length is less than 5, it raises" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        OTT.generate_token!(%{key: :value}, token_length: 4)
      end
    end

    test "when token_length is greater than 100, it raises" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        OTT.generate_token!(%{key: :value}, token_length: 101)
      end
    end

    test "expires_in_minutes can be overrided" do
      utc_now = DateTime.utc_now()
      OTT.generate_token!(%{key: :value}, expires_in_minutes: 3)

      assert [%OneTimeToken{} = one_time_token] = OneTimeToken |> OTT.repo().all()

      assert_in_delta DateTime.to_unix(one_time_token.expired_at),
                      utc_now
                      |> DateTime.add(3, :minute)
                      |> DateTime.to_unix(),
                      5
    end

    test "when token_length is less than 1, it raises" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        OTT.generate_token!(%{key: :value}, expires_in_minutes: 0)
      end
    end
  end

  describe "access_token_data/1" do
    test "when the token is valid, it returns the data and put the token as used" do
      utc_now = DateTime.utc_now()

      token = OTT.generate_token!(%{"key" => "value"})

      assert %{"key" => "value"} = OTT.access_token_data(token)
      assert [%OneTimeToken{} = one_time_token] = OneTimeToken |> OTT.repo().all()

      assert_in_delta DateTime.to_unix(one_time_token.used_at),
                      DateTime.to_unix(utc_now),
                      5

      assert is_nil(one_time_token.revoked_at)
    end

    test "when the token does not exist, it returns nil" do
      assert is_nil(OTT.access_token_data("token"))
    end

    test "when the token is used, it returns nil" do
      utc_now = DateTime.utc_now() |> DateTime.truncate(:second)

      one_time_token =
        %OneTimeToken{
          data: %{},
          expired_at: utc_now |> DateTime.add(5, :minute),
          token: OTT.OneTimeTokens.generate_token(10),
          used_at: utc_now
        }
        |> OTT.repo().insert!()

      assert is_nil(OTT.access_token_data(one_time_token.token))
    end

    test "when the token is revoked, it returns nil" do
      utc_now = DateTime.utc_now() |> DateTime.truncate(:second)

      one_time_token =
        %OneTimeToken{
          data: %{},
          expired_at: utc_now |> DateTime.add(5, :minute),
          token: OTT.OneTimeTokens.generate_token(10),
          used_at: nil,
          revoked_at: utc_now
        }
        |> OTT.repo().insert!()

      assert is_nil(OTT.access_token_data(one_time_token.token))
    end

    # test "when the one_time_token is stale, it returns nil" do
    # end
  end
end
