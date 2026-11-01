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
@onready var target_label: Label = %TargetLabel
@onready var battle_label: Label = %BattleLabel

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

@onready var target_prev_btn: Button = %TargetPrevButton
@onready var target_next_btn: Button = %TargetNextButton
@onready var diplomats_btn: Button = %DiplomatsButton
@onready var alliance_btn: Button = %AllianceButton
@onready var embassy_btn: Button = %EmbassyButton
@onready var attack_btn: Button = %AttackButton
@onready var peace_btn: Button = %PeaceButton
@onready var save_btn: Button = %SaveButton
@onready var load_btn: Button = %LoadButton
@onready var cycle_country_btn: Button = %CycleCountryButton

var _target_index: int = 0
var _playable_ids: Array[String] = []

func _ready() -> void:
	_playable_ids = ["AR", "BR", "CL", "UY", "PE", "CO", "MX", "DE", "FR", "JP"]
	
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
	
	target_prev_btn.pressed.connect(func(): _cycle_target(-1))
	target_next_btn.pressed.connect(func(): _cycle_target(1))
	diplomats_btn.pressed.connect(_on_diplomats)
	alliance_btn.pressed.connect(_on_alliance)
	embassy_btn.pressed.connect(_on_embassy)
	attack_btn.pressed.connect(_on_attack)
	peace_btn.pressed.connect(_on_peace)
	save_btn.pressed.connect(_on_save)
	load_btn.pressed.connect(_on_load)
	cycle_country_btn.pressed.connect(_on_cycle_country)
	
	game_manager.player_stats_updated.connect(_update_ui)
	game_manager.turn_started.connect(func(t): turn_label.text = "Turn %d" % t)
	game_manager.event_occurred.connect(_on_event)
	game_manager.battle_report.connect(_on_battle)
	game_manager.victory_achieved.connect(_on_victory)
	
	_update_target_label()
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
	army_label.text = "Army: %.0f  (Inf %d | Tanks %d | Air %d)" % [
		c.military.total_power, c.military.infantry, c.military.tanks, c.military.aircraft
	]
	nuclear_label.text = "Nuclear: %s (%.0f%%) | Train: %.1f" % [
		"YES" if c.military.has_nuclear_weapons else "No",
		c.military.nuclear_progress,
		c.military.training_level
	]
	resources_label.text = "Food: %.0f | Oil: %.0f | Iron: %.0f | U: %.1f" % [
		c.economy.food, c.economy.oil, c.economy.iron, c.economy.uranium
	]
	_update_target_label()

func _update_target_label() -> void:
	var t = game_manager.get_target()
	if not t or not game_manager.player_country:
		target_label.text = "Target: —"
		return
	var status = game_manager.player_country.diplomacy.get_status_text(t.id)
	target_label.text = "Target: %s | %s | Power %.0f" % [t.name, status, t.military.total_power]

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
		"industry": ok = eco.invest_industry(12.0)
		"agri": ok = eco.invest_agriculture(10.0)
		"energy": ok = eco.invest_energy(11.0)
	print("Invest %s: %s" % [type, "OK" if ok else "FAIL"])
	_update_ui()

func _recruit(type: String) -> void:
	var c = game_manager.player_country
	var ok := false
	match type:
		"inf": ok = c.military.recruit_infantry(10, c.economy)
		"tank": ok = c.military.recruit_tanks(2, c.economy)
	print("Recruit %s: %s" % [type, "OK" if ok else "FAIL"])
	_update_ui()

func _on_train() -> void:
	var c = game_manager.player_country
	print("Train: %s" % ("OK" if c.military.train_army(1.0, c.economy) else "FAIL"))
	_update_ui()

func _on_nuclear() -> void:
	var c = game_manager.player_country
	print("Nuclear: %s" % ("OK" if c.military.invest_nuclear(15.0, c.economy) else "FAIL"))
	_update_ui()

func _on_loan() -> void:
	var eco = game_manager.player_country.economy
	print("Loan: %s" % ("OK" if eco.take_loan(25.0) else "FAIL"))
	_update_ui()

func _cycle_target(dir: int) -> void:
	var others = game_manager.get_other_countries()
	if others.is_empty():
		return
	_target_index = (_target_index + dir) % others.size()
	if _target_index < 0:
		_target_index = others.size() - 1
	game_manager.set_target(others[_target_index].id)
	_update_target_label()

func _on_diplomats() -> void:
	print("Diplomats: %s" % ("OK" if game_manager.diplomats_to_target() else "FAIL"))
	_update_ui()

func _on_alliance() -> void:
	print("Alliance: %s" % ("OK" if game_manager.alliance_with_target() else "FAIL (need ~45 relation)"))
	_update_ui()

func _on_embassy() -> void:
	print("Embassy: %s" % ("OK" if game_manager.embassy_to_target() else "FAIL"))
	_update_ui()

func _on_attack() -> void:
	var report = game_manager.attack_target()
	battle_label.text = report
	_update_ui()

func _on_peace() -> void:
	print("Peace: %s" % ("OK" if game_manager.peace_with_target() else "FAIL"))
	_update_ui()

func _on_save() -> void:
	print("Save: %s" % ("OK" if game_manager.save_game() else "FAIL"))

func _on_load() -> void:
	print("Load: %s" % ("OK" if game_manager.load_game() else "FAIL"))
	_update_ui()

func _on_cycle_country() -> void:
	if _playable_ids.is_empty():
		return
	var current = game_manager.player_country.id if game_manager.player_country else "AR"
	var idx = _playable_ids.find(current)
	idx = (idx + 1) % _playable_ids.size()
	game_manager.select_country(_playable_ids[idx])
	var others = game_manager.get_other_countries()
	if not others.is_empty():
		_target_index = 0
		game_manager.set_target(others[0].id)
	_update_ui()

func _on_event(title: String, description: String) -> void:
	event_label.text = "EVENT: %s — %s" % [title, description]

func _on_battle(report: String) -> void:
	battle_label.text = report

func _on_victory(type: String, message: String) -> void:
	event_label.text = "VICTORY (%s): %s" % [type.to_upper(), message]
	print("[VICTORY] %s" % message)
