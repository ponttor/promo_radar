namespace :instagram do
  desc "Set up Instagram monitoring session via interactive browser login. Run once; re-run when session expires."
  task setup_session: :environment do
    require "playwright"

    print "Enter the Instagram username for the monitoring account: "
    username = $stdin.gets.chomp.strip

    if username.empty?
      puts "Error: username cannot be blank."
      exit 1
    end

    puts "Opening browser... Please log in to Instagram in the window that appears."

    playwright_cli = Rails.root.join("node_modules/.bin/playwright").to_s

    Playwright.create(playwright_cli_executable_path: playwright_cli) do |pw|
      pw.chromium.launch(headless: false) do |browser|
        context = browser.new_context
        page = context.new_page
        page.goto("https://www.instagram.com/accounts/login/")

        puts "Waiting for login to complete (up to 2 minutes)..."

        begin
          page.wait_for_function(
            "() => !window.location.pathname.startsWith('/accounts/')",
            timeout: 120_000
          )
        rescue Playwright::TimeoutError
          puts "Error: Timed out waiting for login. Please try again."
          exit 1
        end

        puts "Login detected! Saving session..."

        storage = context.storage_state

        credential = InstagramCredential.find_or_initialize_by(username: username)
        credential.update!(
          session_json:     storage.to_json,
          active:           true,
          last_verified_at: Time.current
        )

        context.close
        puts "Session saved for @#{username}."
        puts "Run: bin/rails runner \"CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: MonitoringSource.instagram.last)\" to test."
      end
    end
  end
end
