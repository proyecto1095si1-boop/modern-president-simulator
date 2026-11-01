class_name Development
extends RefCounted

## National development sectors (MA3-style internal policy).

signal development_updated

var education: float = 1.0
var infrastructure: float = 1.0
var science: float = 1.0
var culture: float = 1.0
var sports: float = 1.0
var housing: float = 1.0
var justice: float = 1.0
var religion_influence: float = 30.0   # 0-100 soft power path
var ideology_score: float = 50.0      # 0-100 perfect society path

func process_turn(country: Country) -> void:
	# Passive effects
	country.approval = minf(country.approval + (culture - 1.0) * 0.4 + (sports - 1.0) * 0.2, 100.0)
	country.stability = minf(country.stability + (justice - 1.0) * 0.5 + (housing - 1.0) * 0.3, 100.0)
	# Science feeds economy science_level slowly
	country.economy.science_level = maxf(country.economy.science_level, science * 0.9)
	# Ideology drifts toward high development
	var avg = (education + infrastructure + culture + justice + housing) / 5.0
	if avg > 1.5:
		ideology_score = minf(ideology_score + 0.4, 100.0)
	development_updated.emit()

func invest(sector: String, amount: float, economy: Economy) -> bool:
	if economy.treasury < amount or amount <= 0:
		return false
	economy.treasury -= amount
	var gain = amount * 0.03
	match sector:
		"education":
			education = minf(education + gain, 5.0)
		"infrastructure":
			infrastructure = minf(infrastructure + gain, 5.0)
			economy.industry_level += gain * 0.15
		"science":
			science = minf(science + gain, 5.0)
			economy.science_level += gain * 0.2
		"culture":
			culture = minf(culture + gain, 5.0)
		"sports":
			sports = minf(sports + gain, 5.0)
		"housing":
			housing = minf(housing + gain, 5.0)
		"justice":
			justice = minf(justice + gain, 5.0)
		"religion":
			religion_influence = minf(religion_influence + amount * 0.5, 100.0)
		"ideology":
			ideology_score = minf(ideology_score + amount * 0.4, 100.0)
		_:
			return false
	development_updated.emit()
	return true

func summary_line() -> String:
	return "Edu %.1f | Infra %.1f | Sci %.1f | Cult %.1f | Just %.1f | Rel %.0f | Ideol %.0f" % [
		education, infrastructure, science, culture, justice, religion_influence, ideology_score
	]
