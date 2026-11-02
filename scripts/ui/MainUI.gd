extends Control

const MAP_SCENE := preload("res://scenes/map/WorldMap.tscn")

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
@onready var dev_label: Label = %DevLabel
@onready var cabinet_label: Label = %CabinetLabel
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
@onready var map_btn: Button = %MapButton

@onready var hire_btn: Button = %HireMinisterButton
@onready var dev_edu_btn: Button = %DevEduButton
@onready var dev_infra_btn: Button = %DevInfraButton
@onready var dev_sci_btn: Button = %DevScienceButton
@onready var dev_cult_btn: Button = %DevCultureButton
@onready var dev_just_btn: Button = %DevJusticeButton
@onready var dev_rel_btn: Button = %DevReligionButton
@onready var dev_ideo_btn: Button = %DevIdeologyButton
@onready var buy_oil_btn: Button = %BuyOilButton
@onready var buy_food_btn: Button = %BuyFoodButton
@onready var sell_iron_btn: Button = %SellIronButton

var _target_index: int = 0
var _playable_index: int = 0
var _map_instance: Control = null

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
	map_btn.pressed.connect(_on_open_map)
	hire_btn.pressed.connect(_on_hire)
	dev_edu_btn.pressed.connect(func(): _dev("education"))
	dev_infra_btn.pressed.connect(func(): _dev("infrastructure"))
	dev_sci_btn.pressed.connect(func(): _dev("science"))
	dev_cult_btn.pressed.connect(func(): _dev("culture"))
	dev_just_btn.pressed.connect(func(): _dev("justice"))
	dev_rel_btn.pressed.connect(func(): _dev("religion"))
	dev_ideo_btn.pressed.connect(func(): _dev("ideology"))
	buy_oil_btn.pressed.connect(_on_buy_oil)
	buy_food_btn.pressed.connect(_on_buy_food)
	sell_iron_btn.pressed.connect(_on_sell_iron)
	
	game_manager.player_stats_updated.connect(_update_ui)
	game_manager.turn_started.connect(func(t): turn_label.text = "Turn %d" % t)
	game_manager.event_occurred.connect(_on_event)
	game_manager.battle_report.connect(_on_battle)
	game_manager.victory_achieved.connect(_on_victory)
	
	if ProjectSettings.get_setting("game/load_on_start", false):
		ProjectSettings.set_setting("game/load_on_start", false)
		game_manager.load_game()
	
	var ids = game_manager.get_playable_ids()
	if game_manager.player_country:
		var i = ids.find(game_manager.player_country.id)
		if i >= 0:
			_playable_index = i
	_update_ui()
	print("[UI] Ready — %d nations" % ids.size())

func _update_ui() -> void:
	var c = game_manager.player_country
	if not c:
		return
	country_name.text = "%s  (%d nations)" % [c.name, game_manager.countries.size()]
	approval_label.text = "Approval: %.0f%%" % c.approval
	stability_label.text = "Stability: %.0f%%" % c.stability
	gdp_label.text = "GDP: %.1f B" % c.economy.gdp
	treasury_label.text = "Treasury: %.1f B" % c.economy.treasury
	debt_label.text = "Debt: %.1f B | Tax: %.0f%%" % [c.economy.debt, c.economy.tax_rate * 100]
	army_label.text = "Army: %.0f  (Inf %d | Tanks %d | Air %d)" % [
		c.military.total_power, c.military.infantry, c.military.tanks, c.military.aircraft]
	nuclear_label.text = "Nuclear: %s (%.0f%%) | Train: %.1f" % [
		"YES" if c.military.has_nuclear_weapons else "No", c.military.nuclear_progress, c.military.training_level]
	resources_label.text = "Food: %.0f | Oil: %.0f | Iron: %.0f | U: %.1f" % [
		c.economy.food, c.economy.oil, c.economy.iron, c.economy.uranium]
	dev_label.text = "Dev: %s" % c.development.summary_line()
	var cab_parts: Array[String] = []
	for m in c.cabinet.list_hired():
		cab_parts.append("%s(%.1f)" % [m.role_name().substr(0, 3), m.skill])
	cabinet_label.text = "Cabinet (%d): %s" % [c.cabinet.ministers.size(), ", ".join(cab_parts) if cab_parts.size() else "empty — Hire Minister"]
	_update_target_label()

func _update_target_label() -> void:
	var t = game_manager.get_target()
	if not t or not game_manager.player_country:
		target_label.text = "Target: —"
		return
	var status = game_manager.player_country.diplomacy.get_status_text(t.id)
	var total = game_manager.get_other_countries().size()
	target_label.text = "Target: %s | %s | Power %.0f  [%d/%d]" % [
		t.name, status, t.military.total_power, _target_index + 1, maxi(total, 1)]

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
	event_label.text = "Invest %s: %s" % [type, "OK" if ok else "FAIL (treasury?)"]
	_update_ui()

func _recruit(type: String) -> void:
	var c = game_manager.player_country
	var ok := false
	match type:
		"inf": ok = c.military.recruit_infantry(10, c.economy)
		"tank": ok = c.military.recruit_tanks(2, c.economy)
	event_label.text = "Recruit %s: %s" % [type, "OK" if ok else "FAIL"]
	_update_ui()

func _on_train() -> void:
	var c = game_manager.player_country
	event_label.text = "Train: %s" % ("OK" if c.military.train_army(1.0, c.economy) else "FAIL")
	_update_ui()

func _on_nuclear() -> void:
	var c = game_manager.player_country
	event_label.text = "Nuclear: %s" % ("OK" if c.military.invest_nuclear(15.0, c.economy) else "FAIL")
	_update_ui()

func _on_loan() -> void:
	var eco = game_manager.player_country.economy
	event_label.text = "Loan: %s" % ("OK" if eco.take_loan(25.0) else "FAIL")
	_update_ui()

func _on_hire() -> void:
	event_label.text = game_manager.hire_first_available_minister()
	_update_ui()

func _dev(sector: String) -> void:
	var ok = game_manager.invest_development(sector)
	event_label.text = "Develop %s: %s" % [sector, "OK" if ok else "FAIL"]
	_update_ui()

func _on_buy_oil() -> void:
	var msg = Trade.buy_oil(game_manager.player_country, game_manager.get_target())
	event_label.text = msg
	_update_ui()

func _on_buy_food() -> void:
	var msg = Trade.buy_food(game_manager.player_country, game_manager.get_target())
	event_label.text = msg
	_update_ui()

func _on_sell_iron() -> void:
	var msg = Trade.sell_iron(game_manager.player_country, game_manager.get_target())
	event_label.text = msg
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
	event_label.text = "Diplomats: %s" % ("OK" if game_manager.diplomats_to_target() else "FAIL")
	_update_ui()

func _on_alliance() -> void:
	event_label.text = "Alliance: %s" % ("OK" if game_manager.alliance_with_target() else "Need ~45 relation")
	_update_ui()

func _on_embassy() -> void:
	event_label.text = "Embassy: %s" % ("OK" if game_manager.embassy_to_target() else "FAIL")
	_update_ui()

func _on_attack() -> void:
	battle_label.text = game_manager.attack_target()
	_update_ui()

func _on_peace() -> void:
	event_label.text = "Peace: %s" % ("OK" if game_manager.peace_with_target() else "FAIL")
	_update_ui()

func _on_save() -> void:
	event_label.text = "Save: %s" % ("OK" if game_manager.save_game() else "FAIL")

func _on_load() -> void:
	event_label.text = "Load: %s" % ("OK" if game_manager.load_game() else "FAIL")
	_update_ui()

func _on_cycle_country() -> void:
	var ids = game_manager.get_playable_ids()
	if ids.is_empty():
		return
	_playable_index = (_playable_index + 1) % ids.size()
	game_manager.select_country(ids[_playable_index])
	var others = game_manager.get_other_countries()
	if not others.is_empty():
		_target_index = 0
		game_manager.set_target(others[0].id)
	_update_ui()

func _on_open_map() -> void:
	if _map_instance and is_instance_valid(_map_instance):
		_map_instance.visible = true
		if _map_instance.has_method("refresh"):
			_map_instance.refresh()
		return
	_map_instance = MAP_SCENE.instantiate()
	add_child(_map_instance)
	_map_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if _map_instance.has_method("setup"):
		_map_instance.setup(game_manager)
	_map_instance.close_requested.connect(func(): _map_instance.visible = false; _update_ui())
	_map_instance.country_clicked.connect(func(id):
		var others = game_manager.get_other_countries()
		for i in range(others.size()):
			if others[i].id == id:
				_target_index = i
				break
		_update_ui()
	)

func _on_event(title: String, description: String) -> void:
	event_label.text = "EVENT: %s — %s" % [title, description]

func _on_battle(report: String) -> void:
	battle_label.text = report

func _on_victory(type: String, message: String) -> void:
	event_label.text = "VICTORY (%s): %s" % [type.to_upper(), message]
