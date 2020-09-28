defmodule GingerTea.Twilio do
  # no signer
  use Joken.Config, default_signer: nil

  defp twilio_account_sid, do: "ACa47c1ba46e904ef69bc8d8795d2e89ca"
  defp twilio_api_key, do: "SKef06be92d98f99823b4183d1f5e18538"
  defp twilio_api_secret, do: "nHPAbWH0h7ny7A4wl05qysqYdr0f7bVh"

  defp extra_claims(client_name, room_name) do
    %{
      grants: %{
        identity: client_name,
        video: %{
          room: room_name
        }
      }
    }
  end

  @impl true
  def token_config do
    default_claims(skip: [:iss, :jti, :aud, :iat, :nbf])
    |> add_claim("iss", &twilio_api_key/0)
    |> add_claim("jti", fn -> twilio_api_key() <> Integer.to_string(:rand.uniform(9_999_999)) end)
    |> add_claim("sub", fn -> twilio_account_sid() end)
  end

  def generate_access_token(client_id, room_id) do
    signer = Joken.Signer.create("HS256", twilio_api_secret(), %{cty: "twilio-fpa;v=1"})

    case generate_and_sign(extra_claims(client_id, room_id), signer) do
      {:ok, jwt, _claims} -> {:ok, jwt}
      {:error, reason} -> {:error, reason}
    end
  end
end
