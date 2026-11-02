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
@onready var feedback_label: Label = %FeedbackLabel
@onready var tab_overview: Button = %TabOverview
@onready var tab_economy: Button = %TabEconomy
@onready var tab_military: Button = %TabMilitary
@onready var tab_diplo: Button = %TabDiplo
@onready var tab_gov: Button = %TabGov
@onready var panel_overview: Control = %PanelOverview
@onready var panel_economy: Control = %PanelEconomy
@onready var panel_military: Control = %PanelMilitary
@onready var panel_diplo: Control = %PanelDiplo
@onready var panel_gov: Control = %PanelGov
@onready var next_turn_btn: Button = %NextTurnButton
@onready var tax_up_btn: Button = %TaxUpButton
@onready var tax_down_btn: Button = %TaxDownButton
@onready var invest_ind_btn: Button = %InvestIndustryButton
@onready var invest_agr_btn: Button = %InvestAgriButton
@onready var invest_ene_btn: Button = %InvestEnergyButton
@onready var recruit_inf_btn: Button = %RecruitInfButton
@onready var recruit_tank_btn: Button = %RecruitTankButton
@onready var recruit_air_btn: Button = %RecruitAirButton
@onready var recruit_navy_btn: Button = %RecruitNavyButton
@onready var train_btn: Button = %TrainButton
@onready var nuclear_btn: Button = %NuclearButton
@onready var defense_btn: Button = %DefenseButton
@onready var loan_btn: Button = %LoanButton
@onready var target_prev_btn: Button = %TargetPrevButton
@onready var target_next_btn: Button = %TargetNextButton
@onready var diplomats_btn: Button = %DiplomatsButton
@onready var alliance_btn: Button = %AllianceButton
@onready var embassy_btn: Button = %EmbassyButton
@onready var attack_btn: Button = %AttackButton
@onready var peace_btn: Button = %PeaceButton
@onready var recon_btn: Button = %ReconButton
@onready var sabotage_btn: Button = %SabotageButton
@onready var un_condemn_btn: Button = %UNCondemnButton
@onready var un_sanctions_btn: Button = %UNSanctionsButton
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
@onready var candidates_label: Label = %CandidatesLabel
@onready var tutorial_overlay: ColorRect = %TutorialOverlay
@onready var tut_title: Label = %TutTitle
@onready var tut_body: Label = %TutBody
@onready var tut_next: Button = %TutNext

var _target_index: int = 0
var _playable_index: int = 0
var _map_instance: Control = null
var _current_tab: String = "overview"
var _tut_step: int = 0
var _tut_steps: Array = []

func _ready() -> void:
	CommandTheme.apply_to(self)
	_style_special_buttons()
	_connect_all()
	game_manager.player_stats_updated.connect(_update_ui)
	game_manager.turn_started.connect(func(t): turn_label.text = "Turn %d" % t)
	game_manager.event_occurred.connect(_on_event)
	game_manager.battle_report.connect(_on_battle)
	game_manager.victory_achieved.connect(_on_victory)
	game_manager.achievement_unlocked.connect(func(title): _flash("★ %s" % title))
	if ProjectSettings.get_setting("game/load_on_start", false):
		ProjectSettings.set_setting("game/load_on_start", false)
		game_manager.load_game()
	var ids = game_manager.get_playable_ids()
	if game_manager.player_country:
		var i = ids.find(game_manager.player_country.id)
		if i >= 0:
			_playable_index = i
	_show_tab("overview")
	_update_ui()
	_flash("Command center online.")
	_maybe_tutorial()

func _style_special_buttons() -> void:
	var gold = CommandTheme.gold_button_style()
	next_turn_btn.add_theme_stylebox_override("normal", gold)
	next_turn_btn.add_theme_color_override("font_color", CommandTheme.GOLD)
	var danger := StyleBoxFlat.new()
	danger.bg_color = Color(0.35, 0.12, 0.12)
	danger.border_color = CommandTheme.DANGER
	danger.set_border_width_all(1)
	danger.set_corner_radius_all(6)
	danger.content_margin_left = 10
	danger.content_margin_right = 10
	danger.content_margin_top = 10
	danger.content_margin_bottom = 10
	attack_btn.add_theme_stylebox_override("normal", danger)
	attack_btn.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))
	map_btn.add_theme_color_override("font_color", CommandTheme.ACCENT)
	hire_btn.add_theme_color_override("font_color", CommandTheme.SUCCESS)
	country_name.add_theme_color_override("font_color", CommandTheme.GOLD)
	feedback_label.add_theme_color_override("font_color", CommandTheme.TEXT)

func _maybe_tutorial() -> void:
	if not Tutorial.should_show():
		return
	_tut_steps = Tutorial.steps()
	_tut_step = 0
	_show_tut_step()
	tutorial_overlay.visible = true
	tut_next.pressed.connect(_on_tut_next)

func _show_tut_step() -> void:
	if _tut_step >= _tut_steps.size():
		tutorial_overlay.visible = false
		Tutorial.mark_done()
		return
	var s = _tut_steps[_tut_step]
	tut_title.text = s.title
	tut_body.text = s.body
	tut_next.text = "Got it" if _tut_step == _tut_steps.size() - 1 else "Next"

func _on_tut_next() -> void:
	_tut_step += 1
	_show_tut_step()

func _connect_all() -> void:
	tab_overview.pressed.connect(func(): _show_tab("overview"))
	tab_economy.pressed.connect(func(): _show_tab("economy"))
	tab_military.pressed.connect(func(): _show_tab("military"))
	tab_diplo.pressed.connect(func(): _show_tab("diplo"))
	tab_gov.pressed.connect(func(): _show_tab("gov"))
	next_turn_btn.pressed.connect(_on_next_turn)
	tax_up_btn.pressed.connect(func(): _change_tax(0.05))
	tax_down_btn.pressed.connect(func(): _change_tax(-0.05))
	invest_ind_btn.pressed.connect(func(): _invest("industry"))
	invest_agr_btn.pressed.connect(func(): _invest("agri"))
	invest_ene_btn.pressed.connect(func(): _invest("energy"))
	recruit_inf_btn.pressed.connect(func(): _recruit("inf"))
	recruit_tank_btn.pressed.connect(func(): _recruit("tank"))
	recruit_air_btn.pressed.connect(func(): _recruit("air"))
	recruit_navy_btn.pressed.connect(func(): _recruit("navy"))
	train_btn.pressed.connect(_on_train)
	nuclear_btn.pressed.connect(_on_nuclear)
	defense_btn.pressed.connect(_on_defense)
	loan_btn.pressed.connect(_on_loan)
	target_prev_btn.pressed.connect(func(): _cycle_target(-1))
	target_next_btn.pressed.connect(func(): _cycle_target(1))
	diplomats_btn.pressed.connect(_on_diplomats)
	alliance_btn.pressed.connect(_on_alliance)
	embassy_btn.pressed.connect(_on_embassy)
	attack_btn.pressed.connect(_on_attack)
	peace_btn.pressed.connect(_on_peace)
	recon_btn.pressed.connect(_on_recon)
	sabotage_btn.pressed.connect(_on_sabotage)
	un_condemn_btn.pressed.connect(func(): _un(UNSystem.ResType.CONDEMN))
	un_sanctions_btn.pressed.connect(func(): _un(UNSystem.ResType.SANCTIONS))
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

func _show_tab(name: String) -> void:
	_current_tab = name
	panel_overview.visible = name == "overview"
	panel_economy.visible = name == "economy"
	panel_military.visible = name == "military"
	panel_diplo.visible = name == "diplo"
	panel_gov.visible = name == "gov"
	var tabs = {"overview": tab_overview, "economy": tab_economy, "military": tab_military, "diplo": tab_diplo, "gov": tab_gov}
	for k in tabs:
		var b: Button = tabs[k]
		if k == _current_tab:
			b.modulate = Color(1.15, 1.05, 0.7)
			b.add_theme_color_override("font_color", CommandTheme.GOLD)
		else:
			b.modulate = Color(0.85, 0.88, 0.92)
			b.add_theme_color_override("font_color", CommandTheme.TEXT_DIM)

func _flash(msg: String, ok: bool = true) -> void:
	feedback_label.text = msg
	feedback_label.modulate = CommandTheme.SUCCESS if ok else CommandTheme.DANGER
	var tw = create_tween()
	tw.tween_property(feedback_label, "modulate", CommandTheme.TEXT, 0.9)

func _update_ui() -> void:
	var c = game_manager.player_country
	if not c:
		return
	country_name.text = c.name
	turn_label.text = "Turn %d" % game_manager.current_turn
	approval_label.text = "Approval  %.0f%%" % c.approval
	stability_label.text = "Stability  %.0f%%" % c.stability
	gdp_label.text = "GDP  %.1f B" % c.economy.gdp
	treasury_label.text = "Treasury  %.1f B" % c.economy.treasury
	debt_label.text = "Debt %.1f  |  Tax %.0f%%" % [c.economy.debt, c.economy.tax_rate * 100]
	army_label.text = "Army %.0f  Inf %d  Tanks %d  Air %d  Navy %d  SF %d" % [
		c.military.total_power, c.military.infantry, c.military.tanks, c.military.aircraft, c.military.navy, c.military.special_forces]
	nuclear_label.text = "Nuclear: %s (%.0f%%)  Train %.1f  Def %.1f" % [
		"ARMED" if c.military.has_nuclear_weapons else "No", c.military.nuclear_progress, c.military.training_level, c.military.defense_level]
	resources_label.text = "Food %.0f  Oil %.0f  Iron %.0f  U %.1f" % [c.economy.food, c.economy.oil, c.economy.iron, c.economy.uranium]
	dev_label.text = c.development.summary_line()
	var cab_parts: Array[String] = []
	for m in c.cabinet.list_hired():
		cab_parts.append("%s %.1f" % [m.role_name(), m.skill])
	cabinet_label.text = "Cabinet (%d/7): %s" % [c.cabinet.ministers.size(), ", ".join(cab_parts) if cab_parts.size() else "empty"]
	var lines: Array[String] = []
	for cand in game_manager.minister_candidates:
		if cand is Minister and not c.cabinet.has_role(cand.role):
			lines.append("%s — %s  skill %.1f" % [cand.display_name, cand.role_name(), cand.skill])
		if lines.size() >= 6:
			break
	candidates_label.text = "Available:\n" + ("\n".join(lines) if lines.size() else "All roles filled")
	_update_target_label()

func _update_target_label() -> void:
	var t = game_manager.get_target()
	if not t or not game_manager.player_country:
		target_label.text = "Target: —"
		return
	var status = game_manager.player_country.diplomacy.get_status_text(t.id)
	var total = maxi(game_manager.get_other_countries().size(), 1)
	target_label.text = "%s | %s | Power %.0f [%d/%d]" % [t.name, status, t.military.total_power, _target_index + 1, total]

func _on_next_turn() -> void:
	game_manager.next_turn()
	_flash("Turn advanced")

func _change_tax(delta: float) -> void:
	var eco = game_manager.player_country.economy
	eco.set_tax_rate(eco.tax_rate + delta)
	_flash("Tax → %.0f%%" % (eco.tax_rate * 100))
	_update_ui()

func _invest(type: String) -> void:
	var eco = game_manager.player_country.economy
	var ok := false
	match type:
		"industry": ok = eco.invest_industry(12.0)
		"agri": ok = eco.invest_agriculture(10.0)
		"energy": ok = eco.invest_energy(11.0)
	_flash("Invest %s: %s" % [type, "OK" if ok else "Need treasury"], ok)
	_update_ui()

func _recruit(type: String) -> void:
	var c = game_manager.player_country
	var ok := false
	match type:
		"inf": ok = c.military.recruit_infantry(10, c.economy)
		"tank": ok = c.military.recruit_tanks(2, c.economy)
		"air": ok = c.military.recruit_aircraft(1, c.economy)
		"navy": ok = c.military.recruit_navy(1, c.economy)
	_flash("Recruit %s: %s" % [type, "OK" if ok else "FAIL"], ok)
	_update_ui()

func _on_train() -> void:
	var ok = game_manager.player_country.military.train_army(1.0, game_manager.player_country.economy)
	_flash("Train: %s" % ("OK" if ok else "FAIL"), ok)
	_update_ui()

func _on_nuclear() -> void:
	var ok = game_manager.player_country.military.invest_nuclear(15.0, game_manager.player_country.economy)
	_flash("Nuclear: %s" % ("OK" if ok else "FAIL"), ok)
	_update_ui()

func _on_defense() -> void:
	var ok = game_manager.player_country.military.improve_defense(10.0, game_manager.player_country.economy)
	_flash("Defense: %s" % ("OK" if ok else "FAIL"), ok)
	_update_ui()

func _on_loan() -> void:
	var ok = game_manager.player_country.economy.take_loan(25.0)
	_flash("Loan: %s" % ("+25 B" if ok else "Denied"), ok)
	_update_ui()

func _on_hire() -> void:
	var msg = game_manager.hire_first_available_minister()
	_flash(msg, msg.begins_with("Hired"))
	_update_ui()

func _dev(sector: String) -> void:
	var ok = game_manager.invest_development(sector)
	_flash("Develop %s: %s" % [sector, "OK" if ok else "Need treasury"], ok)
	_update_ui()

func _on_buy_oil() -> void:
	var msg = Trade.buy_oil(game_manager.player_country, game_manager.get_target())
	_flash(msg, msg.begins_with("Bought"))
	_update_ui()

func _on_buy_food() -> void:
	var msg = Trade.buy_food(game_manager.player_country, game_manager.get_target())
	_flash(msg, msg.begins_with("Bought"))
	_update_ui()

func _on_sell_iron() -> void:
	var msg = Trade.sell_iron(game_manager.player_country, game_manager.get_target())
	_flash(msg, msg.begins_with("Sold"))
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
	var ok = game_manager.diplomats_to_target()
	_flash("Diplomats: %s" % ("sent" if ok else "FAIL"), ok)
	_update_ui()

func _on_alliance() -> void:
	var ok = game_manager.alliance_with_target()
	_flash("Alliance: %s" % ("formed" if ok else "need ~45 relation"), ok)
	_update_ui()

func _on_embassy() -> void:
	var ok = game_manager.embassy_to_target()
	_flash("Embassy: %s" % ("opened" if ok else "FAIL"), ok)
	_update_ui()

func _on_attack() -> void:
	battle_label.text = game_manager.attack_target()
	_flash("Battle resolved")
	_update_ui()

func _on_peace() -> void:
	var ok = game_manager.peace_with_target()
	_flash("Peace: %s" % ("accepted" if ok else "not at war"), ok)
	_update_ui()

func _on_recon() -> void:
	var msg = Intel.recon(game_manager.player_country, game_manager.get_target())
	battle_label.text = msg
	_flash("Recon complete", msg.find("Need") == -1)
	_update_ui()

func _on_sabotage() -> void:
	var msg = Intel.sabotage(game_manager.player_country, game_manager.get_target())
	battle_label.text = msg
	_flash(msg.substr(0, mini(40, msg.length())), msg.find("SUCCESS") != -1)
	_update_ui()

func _un(kind: UNSystem.ResType) -> void:
	var msg = UNSystem.propose(game_manager.player_country, game_manager.get_target(), kind, game_manager.countries)
	battle_label.text = msg
	_flash(msg.substr(0, mini(50, msg.length())), msg.find("PASSED") != -1)
	_update_ui()

func _on_save() -> void:
	_flash("Saved" if game_manager.save_game() else "Save failed")

func _on_load() -> void:
	var ok = game_manager.load_game()
	_flash("Loaded" if ok else "No save", ok)
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
	_flash("Playing as %s" % game_manager.player_country.name)
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
	event_label.text = "%s — %s" % [title, description]
	_flash("EVENT: %s" % title)

func _on_battle(report: String) -> void:
	battle_label.text = report

func _on_victory(type: String, message: String) -> void:
	event_label.text = "VICTORY (%s): %s" % [type.to_upper(), message]
	_flash("VICTORY — %s" % type.to_upper())
