Plan.update_all available_for_new_subscriptions: false

# free plan
Plan.create! scans_per_month:   100, cost:    0, file_size_limit: 0.5, name: "developer"

#paid plans
Plan.create! scans_per_month:  1000, cost:   75, name: "1,000"
Plan.create! scans_per_month:  2500, cost:  150, name: "2,500"
Plan.create! scans_per_month:  5000, cost:  300, name: "5,000"
Plan.create! scans_per_month: 10000, cost:  600, name: "10,000"
Plan.create! scans_per_month: 20000, cost: 1000, name: "20,000"
Plan.create! scans_per_month: 40000, cost: 2000, name: "40,000"

# special unlimited plan for QAE
Plan.create! name: "alpha-testers", cost: 0, available_for_new_subscriptions: false

# special plan for dashboard demo
Plan.create! name: "dashboard-demo", cost: 0, available_for_new_subscriptions: false, file_size_limit: 0.2

account = Account.create(plan_id:  9)
account.projects.create!(name: 'demo', callback_url: "https://www.vigilion.com/vigilion/callback")
