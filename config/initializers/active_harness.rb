# ActiveHarness v0.2.1 reads OPENROUTER_API_KEY directly from ENV in its
# provider; it does not expose a configure/config DSL.
#
# This initializer validates the key is present at boot time so the app
# fails fast with a clear error rather than at the first AI call.
#
# Defaults baked into the gem:
#   temperature: 0.7  (per-agent override: use `temperature:` in the model DSL)
#   timeout:     30s  (Base provider default)
ENV.fetch("OPENROUTER_API_KEY")
