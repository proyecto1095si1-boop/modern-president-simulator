extends Control

@onready var game_manager: GameManager = $GameManager
@onready var turn_label: Label = %TurnLabel
@onready var country_name: Label = %CountryName
@onready var approval_label: Label = %ApprovalLabel
@onready var stability_label: Label = %StabilityLabel
@onready var gdp_label: Label = %GDPLabel
@onready var treasury_label: Label = %TreasuryLabel
@onready var army_label: Label = %ArmyLabel
@onready var resources_label: Label = %ResourcesLabel
@onready var next_turn_btn: Button = %NextTurnButton
@onready var tax_btn: Button = %TaxButton
@onready var invest_btn: Button = %InvestButton

func _ready() -> void:
	next_turn_btn.pressed.connect(_on_next_turn)
	tax_btn.pressed.connect(_on_raise_tax)
	invest_btn.pressed.connect(_on_invest_industry)
	
	game_manager.player_stats_updated.connect(_update_ui)
	game_manager.turn_started.connect(func(t): turn_label.text = "Turn %d" % t)
	
	_update_ui()

func _update_ui() -> void:
	var c = game_manager.player_country
	if not c:
		return
	
	country_name.text = c.name
	approval_label.text = "Approval: %.0f%%" % c.approval
	stability_label.text = "Stability: %.0f%%" % c.stability
	gdp_label.text = "GDP: %.1f B" % c.economy.gdp
	treasury_label.text = "Treasury: %.1f B" % c.economy.treasury
	army_label.text = "Army Power: %.0f" % c.military.total_power
	resources_label.text = "Food: %.0f | Oil: %.0f | Iron: %.0f" % [
		c.economy.food, c.economy.oil, c.economy.iron
	]

func _on_next_turn() -> void:
	game_manager.next_turn()

func _on_raise_tax() -> void:
	var eco = game_manager.player_country.economy
	eco.set_tax_rate(eco.tax_rate + 0.05)
	_update_ui()
	print("Tax rate now: %.0f%%" % (eco.tax_rate * 100))

func _on_invest_industry() -> void:
	var c = game_manager.player_country
	if c.economy.invest_industry(10.0):
		print("Invested in industry. New level: %.2f" % c.economy.industry_level)
	else:
		print("Not enough money to invest.")
	_update_ui()
