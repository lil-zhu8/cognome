class_name SiteLockUrls

const ALLOWED_REFERRERS:Array = [
	"^cocoamoss\\.com/.*$",
	"^ddrkirby\\.com/.*$",
	"^katmengjia\\.com/.*$",
	"^ddrkirbyisq\\.itch\\.io/.*$",
];

const ALLOWED_URLS:Array = [
	"^file:\\/\\/\\/.*$",
	"^localhost[:\\/].*$",
	"^itch-cave:\\/\\/.*$",
];

static func hasViolation():
	return SiteLock.hasViolation(ALLOWED_REFERRERS, ALLOWED_URLS)
