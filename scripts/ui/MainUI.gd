extends Control

@onready var game_manager: GameManager = $GameManager

@onready var turn_label: Label = %TurnLabel
@onready var country_name: Label = %CountryName
@onready var approval_label: Label = %ApprovalLabel
@onready var stability_label: Label = %StabilityLabel
@onready var gdp_label: Label = %GDPLabel
@onready var treasury_label: Label = %TreasuryLabel
@onready var debt_label: Label = %DebtLabel
@onready var army_label: Label = %ArmyLabel
@onready var nuclear_label: Label = %NuclearLabel
@onready var resources_label: Label = %ResourcesLabel
@onready var event_label: Label = %EventLabel

@onready var next_turn_btn: Button = %NextTurnButton
@onready var tax_up_btn: Button = %TaxUpButton
@onready var tax_down_btn: Button = %TaxDownButton
@onready var invest_ind_btn: Button = %InvestIndustryButton
@onready var invest_agr_btn: Button = %InvestAgriButton
@onready var invest_ene_btn: Button = %InvestEnergyButton
@onready var recruit_inf_btn: Button = %RecruitInfButton
@onready var recruit_tank_btn: Button = %RecruitTankButton
@onready var train_btn: Button = %TrainButton
@onready var nuclear_btn: Button = %NuclearButton
@onready var loan_btn: Button = %LoanButton

func _ready() -> void:
	next_turn_btn.pressed.connect(_on_next_turn)
	tax_up_btn.pressed.connect(func(): _change_tax(0.05))
	tax_down_btn.pressed.connect(func(): _change_tax(-0.05))
	invest_ind_btn.pressed.connect(func(): _invest("industry"))
	invest_agr_btn.pressed.connect(func(): _invest("agri"))
	invest_ene_btn.pressed.connect(func(): _invest("energy"))
	recruit_inf_btn.pressed.connect(func(): _recruit("inf"))
	recruit_tank_btn.pressed.connect(func(): _recruit("tank"))
	train_btn.pressed.connect(_on_train)
	nuclear_btn.pressed.connect(_on_nuclear)
	loan_btn.pressed.connect(_on_loan)
	
	game_manager.player_stats_updated.connect(_update_ui)
	game_manager.turn_started.connect(func(t): turn_label.text = "Turn %d" % t)
	game_manager.event_occurred.connect(_on_event)
	
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
	debt_label.text = "Debt: %.1f B | Tax: %.0f%%" % [c.economy.debt, c.economy.tax_rate * 100]
	army_label.text = "Army Power: %.0f  (Inf %d | Tanks %d | Air %d)" % [
		c.military.total_power, c.military.infantry, c.military.tanks, c.military.aircraft
	]
	nuclear_label.text = "Nuclear: %s (%.0f%%) | Training: %.1f" % [
		"YES" if c.military.has_nuclear_weapons else "No",
		c.military.nuclear_progress,
		c.military.training_level
	]
	resources_label.text = "Food: %.0f | Oil: %.0f | Iron: %.0f | Uranium: %.1f" % [
		c.economy.food, c.economy.oil, c.economy.iron, c.economy.uranium
	]

func _on_next_turn() -> void:
	game_manager.next_turn()

func _change_tax(delta: float) -> void:
	var eco = game_manager.player_country.economy
	eco.set_tax_rate(eco.tax_rate + delta)
	_update_ui()

func _invest(type: String) -> void:
	var eco = game_manager.player_country.economy
	var ok := false
	match type:
		"industry":
			ok = eco.invest_industry(12.0)
		"agri":
			ok = eco.invest_agriculture(10.0)
		"energy":
			ok = eco.invest_energy(11.0)
	if ok:
		print("Investment successful (%s)" % type)
	else:
		print("Not enough money for %s investment" % type)
	_update_ui()

func _recruit(type: String) -> void:
	var c = game_manager.player_country
	var ok := false
	match type:
		"inf":
			ok = c.military.recruit_infantry(10, c.economy)
		"tank":
			ok = c.military.recruit_tanks(2, c.economy)
	if ok:
		print("Recruitment successful")
	else:
		print("Cannot recruit (money or resources)")
	_update_ui()

func _on_train() -> void:
	var c = game_manager.player_country
	if c.military.train_army(1.0, c.economy):
		print("Army training improved")
	else:
		print("Not enough money to train")
	_update_ui()

func _on_nuclear() -> void:
	var c = game_manager.player_country
	if c.military.invest_nuclear(15.0, c.economy):
		print("Nuclear program advanced to %.0f%%" % c.military.nuclear_progress)
	else:
		print("Not enough money for nuclear research")
	_update_ui()

func _on_loan() -> void:
	var eco = game_manager.player_country.economy
	if eco.take_loan(25.0):
		print("Loan taken: +25 B (debt increased)")
	else:
		print("Cannot take more debt")
	_update_ui()

func _on_event(title: String, description: String) -> void:
	event_label.text = "EVENT: %s — %s" % [title, description]
