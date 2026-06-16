from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt
import datetime

# ── Brand palette ────────────────────────────────────────────────────────────
NAVY        = RGBColor(0x0D, 0x2B, 0x55)   # deep navy – headers / title bg
BLUE        = RGBColor(0x1A, 0x5F, 0xA8)   # mid blue – accents
LIGHT_BLUE  = RGBColor(0xE8, 0xF4, 0xFF)   # light blue – section bg
TEAL        = RGBColor(0x00, 0x8B, 0x8B)   # teal – highlights
GREEN       = RGBColor(0x1E, 0x8B, 0x4C)   # green – positive stats
AMBER       = RGBColor(0xF5, 0xA6, 0x23)   # amber – accent bullets
WHITE       = RGBColor(0xFF, 0xFF, 0xFF)
DARK_GRAY   = RGBColor(0x2C, 0x2C, 0x2C)
MID_GRAY    = RGBColor(0x60, 0x60, 0x60)
LIGHT_GRAY  = RGBColor(0xF5, 0xF5, 0xF5)
DIVIDER     = RGBColor(0xD0, 0xD8, 0xE8)

SLIDE_W = Inches(13.33)
SLIDE_H = Inches(7.5)

prs = Presentation()
prs.slide_width  = SLIDE_W
prs.slide_height = SLIDE_H

BLANK = prs.slide_layouts[6]   # completely blank layout


# ── Helper utilities ──────────────────────────────────────────────────────────

def add_rect(slide, l, t, w, h, fill=None, line_color=None, line_width=Pt(0)):
    shape = slide.shapes.add_shape(1, l, t, w, h)   # MSO_SHAPE_TYPE.RECTANGLE = 1
    shape.line.width = line_width
    if fill:
        shape.fill.solid()
        shape.fill.fore_color.rgb = fill
    else:
        shape.fill.background()
    if line_color:
        shape.line.color.rgb = line_color
        shape.line.width = line_width if line_width > Pt(0) else Pt(1)
    else:
        shape.line.fill.background()
    return shape


def add_text_box(slide, text, l, t, w, h,
                 font_size=Pt(12), bold=False, color=DARK_GRAY,
                 align=PP_ALIGN.LEFT, italic=False, wrap=True):
    txb = slide.shapes.add_textbox(l, t, w, h)
    txb.word_wrap = wrap
    tf = txb.text_frame
    tf.word_wrap = wrap
    p = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size = font_size
    run.font.bold = bold
    run.font.italic = italic
    run.font.color.rgb = color
    return txb


def add_para(tf, text, font_size=Pt(11), bold=False, color=DARK_GRAY,
             align=PP_ALIGN.LEFT, space_before=Pt(4), italic=False):
    p = tf.add_paragraph()
    p.alignment = align
    p.space_before = space_before
    run = p.add_run()
    run.text = text
    run.font.size = font_size
    run.font.bold = bold
    run.font.italic = italic
    run.font.color.rgb = color
    return p


def section_header_slide(title, subtitle=""):
    """Full-bleed section divider."""
    slide = prs.slides.add_slide(BLANK)
    add_rect(slide, 0, 0, SLIDE_W, SLIDE_H, fill=NAVY)
    # decorative bar
    add_rect(slide, 0, Inches(3.2), SLIDE_W, Inches(0.08), fill=AMBER)
    add_text_box(slide, title,
                 Inches(1.2), Inches(2.5), Inches(11), Inches(1.2),
                 font_size=Pt(40), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    if subtitle:
        add_text_box(slide, subtitle,
                     Inches(1.5), Inches(3.6), Inches(10), Inches(0.8),
                     font_size=Pt(18), color=RGBColor(0xA8, 0xC8, 0xF0),
                     align=PP_ALIGN.CENTER)
    return slide


def content_slide(title):
    """Standard content slide with navy top bar."""
    slide = prs.slides.add_slide(BLANK)
    # top bar
    add_rect(slide, 0, 0, SLIDE_W, Inches(1.05), fill=NAVY)
    # accent stripe
    add_rect(slide, 0, Inches(1.05), SLIDE_W, Inches(0.06), fill=AMBER)
    # slide background
    add_rect(slide, 0, Inches(1.11), SLIDE_W, SLIDE_H - Inches(1.11), fill=WHITE)
    # title
    add_text_box(slide, title,
                 Inches(0.4), Inches(0.12), Inches(12), Inches(0.85),
                 font_size=Pt(26), bold=True, color=WHITE)
    return slide


def bullet_box(slide, items, l, t, w, h,
               font_size=Pt(11.5), color=DARK_GRAY, bullet="▶  ", bold_first=False):
    txb = slide.shapes.add_textbox(l, t, w, h)
    txb.word_wrap = True
    tf = txb.text_frame
    tf.word_wrap = True
    first = True
    for item in items:
        p = tf.add_paragraph() if not first else tf.paragraphs[0]
        first = False
        p.space_before = Pt(5)
        run = p.add_run()
        run.text = bullet + item
        run.font.size = font_size
        run.font.color.rgb = color
        run.font.bold = bold_first and (items.index(item) == 0)
    return txb


def stat_card(slide, l, t, w, h, number, label, bg=BLUE, num_color=WHITE, lbl_color=WHITE):
    add_rect(slide, l, t, w, h, fill=bg,
             line_color=DIVIDER, line_width=Pt(0.5))
    add_text_box(slide, number,
                 l + Inches(0.1), t + Inches(0.15), w - Inches(0.2), Inches(0.65),
                 font_size=Pt(32), bold=True, color=num_color, align=PP_ALIGN.CENTER)
    add_text_box(slide, label,
                 l + Inches(0.05), t + Inches(0.75), w - Inches(0.1), Inches(0.5),
                 font_size=Pt(10.5), color=lbl_color, align=PP_ALIGN.CENTER, bold=True)


def footer(slide, page_num, total=14):
    add_rect(slide, 0, SLIDE_H - Inches(0.32), SLIDE_W, Inches(0.32), fill=NAVY)
    add_text_box(slide, "ClaimsPro  |  Confidential – For Internal Use Only",
                 Inches(0.3), SLIDE_H - Inches(0.32), Inches(8), Inches(0.32),
                 font_size=Pt(8), color=RGBColor(0xA8, 0xC8, 0xF0))
    add_text_box(slide, f"{page_num} / {total}",
                 Inches(12.2), SLIDE_H - Inches(0.32), Inches(1), Inches(0.32),
                 font_size=Pt(8), color=RGBColor(0xA8, 0xC8, 0xF0), align=PP_ALIGN.RIGHT)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 1 – TITLE
# ═══════════════════════════════════════════════════════════════════════════════
slide = prs.slides.add_slide(BLANK)
# full background
add_rect(slide, 0, 0, SLIDE_W, SLIDE_H, fill=NAVY)
# right-side accent panel
add_rect(slide, Inches(9.5), 0, Inches(3.83), SLIDE_H, fill=BLUE)
# amber accent bar
add_rect(slide, 0, Inches(3.55), Inches(9.5), Inches(0.1), fill=AMBER)

# Logo placeholder box
add_rect(slide, Inches(0.4), Inches(0.3), Inches(2.2), Inches(0.7),
         fill=RGBColor(0x1A, 0x5F, 0xA8), line_color=AMBER, line_width=Pt(1.5))
add_text_box(slide, "CLAIMS PRO",
             Inches(0.42), Inches(0.32), Inches(2.16), Inches(0.66),
             font_size=Pt(13), bold=True, color=AMBER, align=PP_ALIGN.CENTER)

# Main title
add_text_box(slide, "ClaimsPro",
             Inches(0.5), Inches(1.1), Inches(8.8), Inches(1.1),
             font_size=Pt(52), bold=True, color=WHITE)
add_text_box(slide, "Insurance Claims Management System",
             Inches(0.5), Inches(2.2), Inches(8.8), Inches(0.7),
             font_size=Pt(22), color=RGBColor(0xA8, 0xC8, 0xF0))
add_text_box(slide, "End-to-End Digital Claims Processing Platform",
             Inches(0.5), Inches(2.9), Inches(8.8), Inches(0.55),
             font_size=Pt(14), italic=True, color=RGBColor(0x80, 0xB0, 0xD8))

# Right-panel content
add_text_box(slide, "Presented to",
             Inches(9.7), Inches(1.2), Inches(3.4), Inches(0.45),
             font_size=Pt(12), color=RGBColor(0xA8, 0xC8, 0xF0), italic=True)
add_text_box(slide, "Executive Leadership\n& Business Managers",
             Inches(9.7), Inches(1.65), Inches(3.4), Inches(1.0),
             font_size=Pt(16), bold=True, color=WHITE)

add_text_box(slide, "Date",
             Inches(9.7), Inches(3.2), Inches(3.4), Inches(0.4),
             font_size=Pt(11), color=RGBColor(0xA8, 0xC8, 0xF0), italic=True)
add_text_box(slide, datetime.date.today().strftime("%B %d, %Y"),
             Inches(9.7), Inches(3.6), Inches(3.4), Inches(0.5),
             font_size=Pt(14), bold=True, color=WHITE)

# Bottom tagline
add_text_box(slide, "Transforming Claims Operations Through Digital Excellence",
             Inches(0.5), Inches(6.85), Inches(9.0), Inches(0.45),
             font_size=Pt(11), italic=True, color=RGBColor(0x80, 0xB0, 0xD8))

footer(slide, 1)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 2 – AGENDA
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Agenda")
footer(slide, 2)

topics = [
    ("01", "Executive Summary",           "Business challenge & solution overview"),
    ("02", "What is ClaimsPro?",           "Platform capabilities at a glance"),
    ("03", "Claims Lifecycle",             "End-to-end processing workflow"),
    ("04", "User Roles & Responsibilities","Role-based access and accountability"),
    ("05", "Key Features",                 "Functional modules in detail"),
    ("06", "Data & Analytics",             "Dashboard metrics and reporting"),
    ("07", "Technology & Security",        "Architecture, compliance & data safety"),
    ("08", "Business Benefits & ROI",      "Value delivered to the organisation"),
    ("09", "Implementation Roadmap",       "Phased go-live plan"),
    ("10", "Next Steps",                   "Recommended actions"),
]

col_w = Inches(5.9)
row_h = Inches(0.55)
start_l = [Inches(0.45), Inches(6.85)]
start_t = Inches(1.35)

for i, (num, topic, desc) in enumerate(topics):
    col = i % 2
    row = i // 2
    l = start_l[col]
    t = start_t + row * row_h

    bg = LIGHT_BLUE if row % 2 == 0 else WHITE
    add_rect(slide, l, t, col_w, row_h - Inches(0.05),
             fill=bg, line_color=DIVIDER, line_width=Pt(0.5))

    # number badge
    add_rect(slide, l, t, Inches(0.48), row_h - Inches(0.05), fill=NAVY)
    add_text_box(slide, num,
                 l + Inches(0.02), t + Inches(0.08), Inches(0.44), Inches(0.38),
                 font_size=Pt(13), bold=True, color=AMBER, align=PP_ALIGN.CENTER)

    add_text_box(slide, topic,
                 l + Inches(0.55), t + Inches(0.04), Inches(3.0), Inches(0.28),
                 font_size=Pt(12), bold=True, color=NAVY)
    add_text_box(slide, desc,
                 l + Inches(0.55), t + Inches(0.28), Inches(5.2), Inches(0.24),
                 font_size=Pt(9.5), color=MID_GRAY, italic=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 3 – EXECUTIVE SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Executive Summary")
footer(slide, 3)

# Problem panel
add_rect(slide, Inches(0.4), Inches(1.3), Inches(5.9), Inches(2.1),
         fill=RGBColor(0xFF, 0xF0, 0xF0), line_color=RGBColor(0xE0, 0x50, 0x50), line_width=Pt(1.5))
add_rect(slide, Inches(0.4), Inches(1.3), Inches(5.9), Inches(0.38), fill=RGBColor(0xC0, 0x30, 0x30))
add_text_box(slide, "⚠  THE CHALLENGE",
             Inches(0.5), Inches(1.3), Inches(5.7), Inches(0.38),
             font_size=Pt(12), bold=True, color=WHITE)
challenges = [
    "Manual, paper-based claim processing causes delays and errors",
    "No single source of truth – data scattered across departments",
    "Lack of real-time visibility for managers and executives",
    "Inconsistent evaluation & approval decisions across teams",
]
txb = slide.shapes.add_textbox(Inches(0.55), Inches(1.75), Inches(5.65), Inches(1.6))
txb.word_wrap = True
tf = txb.text_frame; tf.word_wrap = True
for i, c in enumerate(challenges):
    p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
    p.space_before = Pt(4)
    r = p.add_run(); r.text = "✗  " + c
    r.font.size = Pt(10.5); r.font.color.rgb = RGBColor(0x80, 0x10, 0x10)

# Solution panel
add_rect(slide, Inches(6.85), Inches(1.3), Inches(6.1), Inches(2.1),
         fill=RGBColor(0xF0, 0xFF, 0xF4), line_color=RGBColor(0x1E, 0x8B, 0x4C), line_width=Pt(1.5))
add_rect(slide, Inches(6.85), Inches(1.3), Inches(6.1), Inches(0.38), fill=GREEN)
add_text_box(slide, "✔  THE SOLUTION — ClaimsPro",
             Inches(6.95), Inches(1.3), Inches(5.9), Inches(0.38),
             font_size=Pt(12), bold=True, color=WHITE)
solutions = [
    "Centralised digital platform for end-to-end claim management",
    "Structured 6-stage workflow with full audit trail",
    "Role-based access ensuring accountability at every step",
    "Real-time dashboard with live statistics and claim tracking",
]
txb = slide.shapes.add_textbox(Inches(7.0), Inches(1.75), Inches(5.8), Inches(1.6))
txb.word_wrap = True
tf = txb.text_frame; tf.word_wrap = True
for i, s in enumerate(solutions):
    p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
    p.space_before = Pt(4)
    r = p.add_run(); r.text = "✔  " + s
    r.font.size = Pt(10.5); r.font.color.rgb = RGBColor(0x0A, 0x5A, 0x2A)

# Key metrics row
metrics = [
    ("6",    "Processing\nStages",        BLUE),
    ("3",    "User\nRoles",               NAVY),
    ("13+",  "Claim Data\nFields Tracked",TEAL),
    ("100%", "Digital\nWorkflow",         GREEN),
    ("24/7", "System\nAvailability",      RGBColor(0x7B, 0x2D, 0x8B)),
]
card_w = Inches(2.4)
for i, (num, lbl, bg) in enumerate(metrics):
    stat_card(slide, Inches(0.4) + i * (card_w + Inches(0.12)),
              Inches(3.6), card_w, Inches(1.35), num, lbl, bg=bg)

# Tagline
add_text_box(slide, "ClaimsPro replaces fragmented manual processes with a single, transparent, auditable digital platform.",
             Inches(0.4), Inches(5.12), Inches(12.5), Inches(0.5),
             font_size=Pt(12.5), bold=True, color=NAVY, align=PP_ALIGN.CENTER, italic=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 4 – WHAT IS CLAIMSPRO?
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("What is ClaimsPro?")
footer(slide, 4)

add_text_box(slide, "A web-based Insurance Claims Management System that digitises and automates the complete claims lifecycle — from first notification to final payout decision.",
             Inches(0.4), Inches(1.2), Inches(12.5), Inches(0.7),
             font_size=Pt(13), color=DARK_GRAY, italic=True)

modules = [
    ("📋", "Claim\nRegistration",  "Capture all claimant, policy, and event details in a structured form with built-in validation"),
    ("🔍", "Initial\nAcceptance",  "Claims Officers review submissions and Accept or Reject with documented reasons"),
    ("📊", "Claim\nEvaluation",    "Case Managers assess claim validity, determine payout amount, and assign risk level"),
    ("✅", "Approval &\nDecision", "Senior approval step with enforced amount caps and mandatory audit notes"),
    ("📈", "Dashboard &\nReports", "Live statistics across all claim stages with search and filter capabilities"),
    ("🔒", "Security &\nAudit",    "Role-based access, session management, and full timestamp audit trail on every action"),
]

mod_w = Inches(3.85)
mod_h = Inches(1.55)
positions = [
    (Inches(0.35), Inches(2.0)),
    (Inches(4.38), Inches(2.0)),
    (Inches(8.41), Inches(2.0)),
    (Inches(0.35), Inches(3.7)),
    (Inches(4.38), Inches(3.7)),
    (Inches(8.41), Inches(3.7)),
]

for i, ((l, t), (icon, title, desc)) in enumerate(zip(positions, modules)):
    add_rect(slide, l, t, mod_w, mod_h, fill=LIGHT_BLUE,
             line_color=BLUE, line_width=Pt(0.8))
    add_rect(slide, l, t, Inches(0.62), mod_h, fill=NAVY)
    add_text_box(slide, icon,
                 l + Inches(0.04), t + Inches(0.4), Inches(0.54), Inches(0.65),
                 font_size=Pt(22), align=PP_ALIGN.CENTER)
    add_text_box(slide, title,
                 l + Inches(0.7), t + Inches(0.08), Inches(3.05), Inches(0.52),
                 font_size=Pt(12), bold=True, color=NAVY)
    add_text_box(slide, desc,
                 l + Inches(0.7), t + Inches(0.55), Inches(3.1), Inches(0.95),
                 font_size=Pt(10), color=DARK_GRAY, wrap=True)

add_text_box(slide, "Built on Spring Boot 2.7  •  Java 17  •  Apache Tomcat  •  REST APIs  •  Responsive Web UI",
             Inches(0.4), Inches(5.45), Inches(12.5), Inches(0.35),
             font_size=Pt(10), color=MID_GRAY, align=PP_ALIGN.CENTER, italic=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 5 – CLAIMS LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Claims Lifecycle — End-to-End Workflow")
footer(slide, 5)

stages = [
    ("SUBMITTED",        "01", BLUE,                    "Claim registered\nby Officer"),
    ("ACCEPTED /\nREJECTED", "02", TEAL,               "Initial review\ncomplete"),
    ("UNDER\nEVALUATION","03", RGBColor(0x7B,0x2D,0x8B),"Evaluator\nassigned"),
    ("EVALUATED",        "04", RGBColor(0xE6,0x7E,0x22),"Amount &\nrisk set"),
    ("APPROVED /\nDENIED","05", GREEN,                  "Final payout\ndecision"),
]

box_w = Inches(2.1)
box_h = Inches(2.2)
gap   = Inches(0.3)
start_l = Inches(0.4)
top   = Inches(1.5)

for i, (label, num, color, sub) in enumerate(stages):
    l = start_l + i * (box_w + gap)
    # main box
    add_rect(slide, l, top, box_w, box_h, fill=color,
             line_color=WHITE, line_width=Pt(1.5))
    # step number
    add_text_box(slide, num,
                 l + Inches(0.05), top + Inches(0.05), box_w - Inches(0.1), Inches(0.52),
                 font_size=Pt(28), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    # label
    add_text_box(slide, label,
                 l + Inches(0.05), top + Inches(0.55), box_w - Inches(0.1), Inches(0.9),
                 font_size=Pt(13), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    # sub
    add_text_box(slide, sub,
                 l + Inches(0.05), top + Inches(1.45), box_w - Inches(0.1), Inches(0.7),
                 font_size=Pt(9.5), color=RGBColor(0xD0, 0xE8, 0xFF), align=PP_ALIGN.CENTER)
    # arrow (not after last)
    if i < len(stages) - 1:
        add_text_box(slide, "→",
                     l + box_w + Inches(0.02), top + Inches(0.75), gap, Inches(0.6),
                     font_size=Pt(22), bold=True, color=NAVY, align=PP_ALIGN.CENTER)

# Rules box
add_rect(slide, Inches(0.4), Inches(3.9), Inches(12.5), Inches(1.85),
         fill=LIGHT_BLUE, line_color=DIVIDER, line_width=Pt(0.8))
add_text_box(slide, "Business Rules Enforced at Every Stage",
             Inches(0.6), Inches(3.98), Inches(12.0), Inches(0.38),
             font_size=Pt(13), bold=True, color=NAVY)

rules = [
    "Rejection requires a mandatory written reason — no silent rejections",
    "Approved payout amount cannot exceed the Evaluator's assessed amount",
    "Evaluation notes minimum 20 characters — ensures documented decisions",
    "Risk classification mandatory (Low / Medium / High) at evaluation stage",
    "Complete timestamp + user audit trail captured at every state transition",
    "Dates cannot be set in the future — prevents backdating of claims",
]

for i, rule in enumerate(rules):
    col = i % 3
    row = i // 3
    add_text_box(slide, "●  " + rule,
                 Inches(0.6) + col * Inches(4.2), Inches(4.45) + row * Inches(0.42),
                 Inches(4.1), Inches(0.42),
                 font_size=Pt(9.5), color=DARK_GRAY)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 6 – USER ROLES
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("User Roles & Responsibilities")
footer(slide, 6)

add_text_box(slide, "ClaimsPro implements a three-tier role hierarchy ensuring clear accountability and separation of duties across the claims process.",
             Inches(0.4), Inches(1.2), Inches(12.5), Inches(0.5),
             font_size=Pt(12), color=DARK_GRAY, italic=True)

roles = [
    (
        "ADMINISTRATOR",
        NAVY,
        "admin@claims.com",
        [
            "Full system access and oversight",
            "User and access management",
            "System configuration",
            "All report and dashboard access",
            "Audit log review",
        ],
        "System Owner / IT Admin"
    ),
    (
        "CLAIMS OFFICER",
        BLUE,
        "officer@claims.com",
        [
            "Register new claims (FNOL)",
            "Review and Accept / Reject submissions",
            "Initiate evaluation process",
            "Manage claim documentation",
            "Update claim officer notes",
        ],
        "Front-line Claims Handler"
    ),
    (
        "CASE MANAGER",
        TEAL,
        "manager@claims.com",
        [
            "Conduct detailed claim evaluation",
            "Determine assessed payout amount",
            "Assign risk level (Low / Medium / High)",
            "Document recommendation and findings",
            "Approve or Deny evaluated claims",
        ],
        "Senior Claims Decision Maker"
    ),
]

card_w = Inches(3.95)
for i, (role, color, email, duties, position) in enumerate(roles):
    l = Inches(0.4) + i * (card_w + Inches(0.28))
    t = Inches(1.85)

    add_rect(slide, l, t, card_w, Inches(4.3), fill=WHITE,
             line_color=color, line_width=Pt(2))
    add_rect(slide, l, t, card_w, Inches(0.72), fill=color)

    add_text_box(slide, role,
                 l + Inches(0.1), t + Inches(0.06), card_w - Inches(0.2), Inches(0.38),
                 font_size=Pt(14), bold=True, color=WHITE)
    add_text_box(slide, position,
                 l + Inches(0.1), t + Inches(0.44), card_w - Inches(0.2), Inches(0.28),
                 font_size=Pt(9.5), color=RGBColor(0xD0, 0xE8, 0xFF), italic=True)

    add_text_box(slide, "Key Responsibilities:",
                 l + Inches(0.15), t + Inches(0.85), card_w - Inches(0.25), Inches(0.32),
                 font_size=Pt(10.5), bold=True, color=color)

    for j, duty in enumerate(duties):
        add_text_box(slide, "▸  " + duty,
                     l + Inches(0.15), t + Inches(1.2) + j * Inches(0.55),
                     card_w - Inches(0.25), Inches(0.52),
                     font_size=Pt(10.5), color=DARK_GRAY)

# Separation note
add_rect(slide, Inches(0.4), Inches(6.3), Inches(12.5), Inches(0.5),
         fill=RGBColor(0xFF, 0xF8, 0xE0), line_color=AMBER, line_width=Pt(1))
add_text_box(slide, "⚖  Segregation of Duties:  Registration → Acceptance (Officer)  |  Evaluation → Approval (Manager)  — prevents single-person fraud risk",
             Inches(0.6), Inches(6.32), Inches(12.1), Inches(0.45),
             font_size=Pt(10.5), color=RGBColor(0x80, 0x50, 0x00), bold=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 7 – KEY FEATURES
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Key Features")
footer(slide, 7)

# Left column
add_rect(slide, Inches(0.35), Inches(1.3), Inches(6.1), Inches(4.9),
         fill=LIGHT_BLUE, line_color=DIVIDER, line_width=Pt(0.8))
add_rect(slide, Inches(0.35), Inches(1.3), Inches(6.1), Inches(0.45), fill=NAVY)
add_text_box(slide, "  Operational Features",
             Inches(0.4), Inches(1.32), Inches(6.0), Inches(0.42),
             font_size=Pt(13), bold=True, color=WHITE)

op_features = [
    ("Comprehensive Claim Registration",
     "Captures 30+ data points: insured details, event info, reporter data, agent codes, policy types"),
    ("Multi-Stage Workflow Automation",
     "Guided 6-step process eliminates skipped stages; system enforces correct sequence"),
    ("Advanced Search & Filtering",
     "Filter claims by status, claim type, or free-text search across claimant names and IDs"),
    ("Real-Time Statistics Dashboard",
     "Live counts per stage + total approved payout amounts visible to all authorised users"),
    ("Complete Audit Trail",
     "Every action captures user, timestamp, and reason — meets regulatory documentation requirements"),
]
for i, (title, desc) in enumerate(op_features):
    t_offset = Inches(1.85) + i * Inches(0.88)
    add_text_box(slide, "◆  " + title,
                 Inches(0.5), t_offset, Inches(5.8), Inches(0.3),
                 font_size=Pt(11), bold=True, color=NAVY)
    add_text_box(slide, "    " + desc,
                 Inches(0.5), t_offset + Inches(0.3), Inches(5.8), Inches(0.5),
                 font_size=Pt(9.8), color=MID_GRAY, wrap=True)

# Right column
add_rect(slide, Inches(6.9), Inches(1.3), Inches(6.1), Inches(4.9),
         fill=RGBColor(0xF0, 0xFF, 0xF4), line_color=DIVIDER, line_width=Pt(0.8))
add_rect(slide, Inches(6.9), Inches(1.3), Inches(6.1), Inches(0.45), fill=GREEN)
add_text_box(slide, "  Management & Control Features",
             Inches(6.95), Inches(1.32), Inches(6.0), Inches(0.42),
             font_size=Pt(13), bold=True, color=WHITE)

mgmt_features = [
    ("Role-Based Access Control",
     "Each user sees only what their role permits — Officers cannot approve, Managers cannot register"),
    ("Business Rule Enforcement",
     "Approved amount cap, mandatory rejection reasons, evaluation note minimums — hardcoded guardrails"),
    ("Session-Based Security",
     "30-minute session timeout, authenticated pages, secure login/logout — prevents unauthorised access"),
    ("Data Validation & Quality",
     "Email format checks, future-date prevention, required field validation at data entry point"),
    ("Scalable REST API Architecture",
     "13 RESTful endpoints — ready for integration with core insurance systems, portals, or mobile apps"),
]
for i, (title, desc) in enumerate(mgmt_features):
    t_offset = Inches(1.85) + i * Inches(0.88)
    add_text_box(slide, "◆  " + title,
                 Inches(7.05), t_offset, Inches(5.8), Inches(0.3),
                 font_size=Pt(11), bold=True, color=GREEN)
    add_text_box(slide, "    " + desc,
                 Inches(7.05), t_offset + Inches(0.3), Inches(5.8), Inches(0.5),
                 font_size=Pt(9.8), color=MID_GRAY, wrap=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 8 – DATA & ANALYTICS DASHBOARD
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Data & Analytics — Live Dashboard")
footer(slide, 8)

add_text_box(slide, "The ClaimsPro dashboard delivers real-time operational intelligence to Officers, Managers and Executives.",
             Inches(0.4), Inches(1.2), Inches(12.5), Inches(0.42),
             font_size=Pt(12), italic=True, color=DARK_GRAY)

# KPI cards row 1
kpis_r1 = [
    ("Total Claims",      NAVY,  "All claims in system"),
    ("Submitted",         BLUE,  "Awaiting initial review"),
    ("Accepted",          TEAL,  "Passed initial check"),
    ("Under Evaluation",  RGBColor(0x7B,0x2D,0x8B), "Being assessed"),
]
kpis_r2 = [
    ("Evaluated",         RGBColor(0xE6,0x7E,0x22), "Assessment complete"),
    ("Approved",          GREEN,  "Payout authorised"),
    ("Rejected / Denied", RGBColor(0xC0,0x30,0x30), "Declined claims"),
    ("Total Approved $",  RGBColor(0x1A,0x70,0x40), "Sum of payouts"),
]

kw = Inches(2.9)
kh = Inches(1.25)
for i, (label, color, sub) in enumerate(kpis_r1):
    l = Inches(0.4) + i * (kw + Inches(0.14))
    add_rect(slide, l, Inches(1.75), kw, kh, fill=color,
             line_color=WHITE, line_width=Pt(1))
    add_text_box(slide, "—", l + Inches(0.1), Inches(1.82), kw - Inches(0.2), Inches(0.52),
                 font_size=Pt(26), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, label, l + Inches(0.05), Inches(2.33), kw - Inches(0.1), Inches(0.28),
                 font_size=Pt(11), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, sub, l + Inches(0.05), Inches(2.6), kw - Inches(0.1), Inches(0.28),
                 font_size=Pt(8.5), color=RGBColor(0xD0,0xE8,0xFF), align=PP_ALIGN.CENTER, italic=True)

for i, (label, color, sub) in enumerate(kpis_r2):
    l = Inches(0.4) + i * (kw + Inches(0.14))
    add_rect(slide, l, Inches(3.1), kw, kh, fill=color,
             line_color=WHITE, line_width=Pt(1))
    add_text_box(slide, "—", l + Inches(0.1), Inches(3.17), kw - Inches(0.2), Inches(0.52),
                 font_size=Pt(26), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, label, l + Inches(0.05), Inches(3.68), kw - Inches(0.1), Inches(0.28),
                 font_size=Pt(11), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, sub, l + Inches(0.05), Inches(3.95), kw - Inches(0.1), Inches(0.28),
                 font_size=Pt(8.5), color=RGBColor(0xD0,0xE8,0xFF), align=PP_ALIGN.CENTER, italic=True)

# Capabilities box
add_rect(slide, Inches(0.4), Inches(4.5), Inches(12.5), Inches(1.65),
         fill=LIGHT_BLUE, line_color=DIVIDER, line_width=Pt(0.8))
add_text_box(slide, "Dashboard Capabilities",
             Inches(0.6), Inches(4.58), Inches(12.0), Inches(0.38),
             font_size=Pt(13), bold=True, color=NAVY)

caps = [
    "Filter claims by Status, Type, or free-text search",
    "View complete claim history with full audit trail",
    "Track payout exposure across all approved claims",
    "Monitor claims officer and manager workload",
    "Identify bottlenecks in the evaluation pipeline",
    "Export-ready data structure for BI integration",
]
for i, cap in enumerate(caps):
    col = i % 3
    row = i // 3
    add_text_box(slide, "✔  " + cap,
                 Inches(0.6) + col * Inches(4.2), Inches(5.05) + row * Inches(0.42),
                 Inches(4.1), Inches(0.4),
                 font_size=Pt(10), color=DARK_GRAY)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 9 – TECHNOLOGY & SECURITY
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Technology & Security")
footer(slide, 9)

# Tech stack
add_rect(slide, Inches(0.35), Inches(1.3), Inches(5.9), Inches(4.85),
         fill=LIGHT_BLUE, line_color=DIVIDER, line_width=Pt(0.8))
add_rect(slide, Inches(0.35), Inches(1.3), Inches(5.9), Inches(0.45), fill=NAVY)
add_text_box(slide, "  Technology Stack",
             Inches(0.4), Inches(1.32), Inches(5.8), Inches(0.42),
             font_size=Pt(13), bold=True, color=WHITE)

tech = [
    ("Backend Framework",  "Spring Boot 2.7.18 (Spring MVC 5.3)"),
    ("Runtime",            "Java 17 (LTS) — enterprise grade & secure"),
    ("Web Server",         "Apache Tomcat 9.0 (embedded)"),
    ("View Layer",         "JSP with JSTL — server-side rendering"),
    ("Data Validation",    "Hibernate Validator / Bean Validation API"),
    ("Serialisation",      "Jackson 2.13 (JSON REST API)"),
    ("Build Tool",         "Apache Maven 3.8"),
    ("Deployment",         "Self-contained WAR — deploy anywhere"),
    ("Frontend",           "Vanilla JS + Custom CSS — no heavy frameworks"),
]
for i, (label, value) in enumerate(tech):
    t = Inches(1.9) + i * Inches(0.47)
    add_text_box(slide, label + ":",
                 Inches(0.5), t, Inches(1.85), Inches(0.4),
                 font_size=Pt(10), bold=True, color=NAVY)
    add_text_box(slide, value,
                 Inches(2.38), t, Inches(3.7), Inches(0.4),
                 font_size=Pt(10), color=DARK_GRAY)

# Security column
add_rect(slide, Inches(6.9), Inches(1.3), Inches(6.1), Inches(4.85),
         fill=RGBColor(0xF0, 0xFF, 0xF4), line_color=DIVIDER, line_width=Pt(0.8))
add_rect(slide, Inches(6.9), Inches(1.3), Inches(6.1), Inches(0.45), fill=GREEN)
add_text_box(slide, "  Security & Compliance Controls",
             Inches(6.95), Inches(1.32), Inches(5.9), Inches(0.42),
             font_size=Pt(13), bold=True, color=WHITE)

security = [
    ("Authentication",     "Email + Password with server-side validation"),
    ("Session Management", "HTTP Session with 30-minute auto-timeout"),
    ("Authorisation",      "Role checks on every protected API endpoint"),
    ("Page Security",      "Server-side auth guards on all JSP views"),
    ("Input Validation",   "Bean Validation + custom business rules"),
    ("SQL Injection",      "No raw SQL — in-memory store, no injection surface"),
    ("Audit Logging",      "Full user + timestamp trail on all state changes"),
    ("Data Integrity",     "Immutable DTOs — requests never mutate entity directly"),
    ("Future Roadmap",     "Database persistence, HTTPS, SSO / Active Directory"),
]
for i, (label, value) in enumerate(security):
    t = Inches(1.9) + i * Inches(0.47)
    add_text_box(slide, label + ":",
                 Inches(7.05), t, Inches(1.85), Inches(0.4),
                 font_size=Pt(10), bold=True, color=GREEN)
    add_text_box(slide, value,
                 Inches(8.95), t, Inches(3.9), Inches(0.4),
                 font_size=Pt(10), color=DARK_GRAY)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 10 – BUSINESS BENEFITS & ROI
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Business Benefits & Return on Investment")
footer(slide, 10)

add_text_box(slide, "ClaimsPro delivers measurable value across operational efficiency, risk management, customer experience and regulatory compliance.",
             Inches(0.4), Inches(1.2), Inches(12.5), Inches(0.45),
             font_size=Pt(11.5), italic=True, color=DARK_GRAY)

benefits = [
    (NAVY,  "Operational\nEfficiency",
     ["Eliminates paper-based manual processing",
      "Structured workflow reduces handling time",
      "No lost or misfiled claims",
      "Officers focused on decisions, not admin"]),
    (BLUE,  "Risk &\nFraud Control",
     ["Segregation of duties prevents single-person fraud",
      "Mandatory documented justifications",
      "Enforced payout caps at approval stage",
      "Complete audit trail for investigations"]),
    (GREEN, "Customer\nExperience",
     ["Faster claim decisions through digital flow",
      "Consistent, fair evaluation process",
      "Transparent status tracking",
      "Fewer errors = fewer claimant disputes"]),
    (TEAL,  "Regulatory &\nCompliance",
     ["Full audit log meets documentation requirements",
      "Enforced workflow prevents process bypassing",
      "Timestamped decisions for dispute resolution",
      "Data validation ensures record integrity"]),
    (RGBColor(0x7B,0x2D,0x8B), "Executive\nVisibility",
     ["Real-time claim counts by stage",
      "Total approved payout exposure at a glance",
      "Bottleneck identification in pipeline",
      "Foundation for BI and predictive analytics"]),
]

bw = Inches(2.38)
bh = Inches(4.0)
for i, (color, title, points) in enumerate(benefits):
    l = Inches(0.35) + i * (bw + Inches(0.1))
    add_rect(slide, l, Inches(1.78), bw, bh, fill=WHITE,
             line_color=color, line_width=Pt(2))
    add_rect(slide, l, Inches(1.78), bw, Inches(0.68), fill=color)
    add_text_box(slide, title,
                 l + Inches(0.08), Inches(1.82), bw - Inches(0.16), Inches(0.62),
                 font_size=Pt(12), bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    for j, pt in enumerate(points):
        add_text_box(slide, "▸  " + pt,
                     l + Inches(0.1), Inches(2.58) + j * Inches(0.72),
                     bw - Inches(0.18), Inches(0.68),
                     font_size=Pt(9.8), color=DARK_GRAY, wrap=True)

add_rect(slide, Inches(0.35), Inches(5.95), Inches(12.5), Inches(0.5),
         fill=RGBColor(0xFF, 0xF8, 0xE0), line_color=AMBER, line_width=Pt(1))
add_text_box(slide, "💡  ClaimsPro is the operational backbone that turns claims processing from a cost centre into a competitive advantage.",
             Inches(0.55), Inches(5.98), Inches(12.2), Inches(0.45),
             font_size=Pt(11), bold=True, color=RGBColor(0x80, 0x50, 0x00))


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 11 – SCREEN WALKTHROUGH
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Application Screen Overview")
footer(slide, 11)

screens = [
    ("Login Portal",
     "Secure email + password authentication with session management and automatic redirect to dashboard.",
     NAVY, "/login"),
    ("Operations Dashboard",
     "Real-time KPI cards showing claims at every stage plus total approved payout value with search & filter.",
     BLUE, "/dashboard"),
    ("Claim Registration",
     "30+ field intake form capturing insured, claimant, reporter, agent and policy data with validation.",
     TEAL, "/case-registration"),
    ("Acceptance Review",
     "Tabular view of SUBMITTED claims with one-click Accept or Reject with mandatory notes capture.",
     RGBColor(0x7B,0x2D,0x8B), "/case-acceptance"),
    ("Claim Evaluation",
     "Evaluation workspace showing claim details; Evaluator sets amount, risk level and recommendation.",
     RGBColor(0xE6,0x7E,0x22), "/case-evaluation"),
    ("Approval / Decision",
     "Final decision screen with enforced amount cap; Manager enters approval amount and authorisation notes.",
     GREEN, "/case-approval"),
]

sw = Inches(3.85)
sh = Inches(2.2)
positions2 = [
    (Inches(0.35), Inches(1.35)),
    (Inches(4.35), Inches(1.35)),
    (Inches(8.35), Inches(1.35)),
    (Inches(0.35), Inches(3.7)),
    (Inches(4.35), Inches(3.7)),
    (Inches(8.35), Inches(3.7)),
]
for (l, t), (name, desc, color, route) in zip(positions2, screens):
    add_rect(slide, l, t, sw, sh, fill=WHITE,
             line_color=color, line_width=Pt(1.5))
    add_rect(slide, l, t, sw, Inches(0.42), fill=color)
    add_text_box(slide, name,
                 l + Inches(0.1), t + Inches(0.05), sw - Inches(0.2), Inches(0.35),
                 font_size=Pt(12), bold=True, color=WHITE)
    add_text_box(slide, route,
                 l + sw - Inches(1.5), t + Inches(0.05), Inches(1.4), Inches(0.35),
                 font_size=Pt(9), color=RGBColor(0xD0,0xE8,0xFF), align=PP_ALIGN.RIGHT)
    # mock browser bar
    add_rect(slide, l + Inches(0.1), t + Inches(0.5), sw - Inches(0.2), Inches(0.3),
             fill=LIGHT_GRAY, line_color=DIVIDER, line_width=Pt(0.5))
    add_text_box(slide, "localhost:9090" + route,
                 l + Inches(0.15), t + Inches(0.52), sw - Inches(0.25), Inches(0.28),
                 font_size=Pt(8), color=MID_GRAY)
    # description
    add_text_box(slide, desc,
                 l + Inches(0.1), t + Inches(0.9), sw - Inches(0.2), Inches(1.2),
                 font_size=Pt(10), color=DARK_GRAY, wrap=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 12 – IMPLEMENTATION ROADMAP
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Implementation Roadmap")
footer(slide, 12)

add_text_box(slide, "A phased approach ensures stable delivery with minimal business disruption.",
             Inches(0.4), Inches(1.2), Inches(12.5), Inches(0.42),
             font_size=Pt(12), italic=True, color=DARK_GRAY)

phases = [
    ("Phase 1\nFoundation",      "Weeks 1–2",   BLUE,
     ["Deploy ClaimsPro to production server",
      "Configure HTTPS / SSL certificate",
      "Migrate existing claim register to digital",
      "User accounts creation and role assignment",
      "Staff training (Officers & Managers)"]),
    ("Phase 2\nEnhancement",     "Weeks 3–6",   TEAL,
     ["Connect to core insurance database (DB)",
      "Active Directory / SSO integration",
      "Email notifications at each stage change",
      "Document attachment support",
      "Advanced reporting & export (PDF/Excel)"]),
    ("Phase 3\nScale & Optimise","Weeks 7–12",  NAVY,
     ["Customer self-service portal (claimant view)",
      "Mobile responsive UI enhancements",
      "Predictive risk scoring (AI/ML module)",
      "SLA tracking and automated escalations",
      "BI dashboard integration (Power BI / Tableau)"]),
    ("Phase 4\nFuture Vision",   "Quarter 3+",  GREEN,
     ["API gateway for third-party integrations",
      "Automated document OCR intake",
      "Real-time fraud detection engine",
      "Multi-company / multi-branch support",
      "Claims analytics and trend forecasting"]),
]

pw = Inches(2.9)
ph = Inches(4.5)
for i, (phase, timeline, color, tasks) in enumerate(phases):
    l = Inches(0.35) + i * (pw + Inches(0.18))
    add_rect(slide, l, Inches(1.75), pw, ph, fill=WHITE,
             line_color=color, line_width=Pt(2))
    add_rect(slide, l, Inches(1.75), pw, Inches(0.78), fill=color)
    add_text_box(slide, phase,
                 l + Inches(0.1), Inches(1.78), pw - Inches(0.2), Inches(0.5),
                 font_size=Pt(13), bold=True, color=WHITE)
    # timeline badge
    add_rect(slide, l + Inches(0.1), Inches(2.52), pw - Inches(0.2), Inches(0.28),
             fill=RGBColor(0xE8,0xF4,0xFF), line_color=color, line_width=Pt(0.8))
    add_text_box(slide, "⏱  " + timeline,
                 l + Inches(0.12), Inches(2.52), pw - Inches(0.22), Inches(0.28),
                 font_size=Pt(9.5), bold=True, color=color)
    for j, task in enumerate(tasks):
        add_text_box(slide, "▸  " + task,
                     l + Inches(0.1), Inches(2.9) + j * Inches(0.58),
                     pw - Inches(0.2), Inches(0.55),
                     font_size=Pt(9.5), color=DARK_GRAY, wrap=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 13 – NEXT STEPS
# ═══════════════════════════════════════════════════════════════════════════════
slide = content_slide("Next Steps & Recommended Actions")
footer(slide, 13)

# Immediate actions
add_rect(slide, Inches(0.35), Inches(1.3), Inches(8.2), Inches(4.85),
         fill=LIGHT_BLUE, line_color=DIVIDER, line_width=Pt(0.8))
add_rect(slide, Inches(0.35), Inches(1.3), Inches(8.2), Inches(0.45), fill=NAVY)
add_text_box(slide, "  Immediate Actions (This Month)",
             Inches(0.4), Inches(1.32), Inches(8.1), Inches(0.42),
             font_size=Pt(13), bold=True, color=WHITE)

actions = [
    ("01", "Executive Sign-Off",
     "Obtain business approval to proceed with Phase 1 production deployment"),
    ("02", "IT Infrastructure Review",
     "Confirm server specification, SSL certificate and network access requirements"),
    ("03", "User Acceptance Testing",
     "Pilot with 2–3 Claims Officers and 1 Case Manager using real (sanitised) claim data"),
    ("04", "Data Migration Plan",
     "Inventory existing manual claims to be migrated; define data entry approach"),
    ("05", "Training Programme",
     "Schedule half-day training sessions for all staff before go-live date"),
    ("06", "Go-Live Date",
     "Target production launch — recommended within 4 weeks of executive approval"),
]
for i, (num, title, desc) in enumerate(actions):
    t = Inches(1.9) + i * Inches(0.69)
    add_rect(slide, Inches(0.45), t, Inches(0.5), Inches(0.55), fill=NAVY)
    add_text_box(slide, num,
                 Inches(0.46), t + Inches(0.08), Inches(0.48), Inches(0.4),
                 font_size=Pt(12), bold=True, color=AMBER, align=PP_ALIGN.CENTER)
    add_text_box(slide, title,
                 Inches(1.05), t + Inches(0.04), Inches(7.3), Inches(0.28),
                 font_size=Pt(11), bold=True, color=NAVY)
    add_text_box(slide, desc,
                 Inches(1.05), t + Inches(0.3), Inches(7.3), Inches(0.35),
                 font_size=Pt(9.8), color=MID_GRAY)

# Right: Key questions
add_rect(slide, Inches(8.95), Inches(1.3), Inches(4.0), Inches(4.85),
         fill=RGBColor(0xFF, 0xF8, 0xE0), line_color=AMBER, line_width=Pt(1.5))
add_rect(slide, Inches(8.95), Inches(1.3), Inches(4.0), Inches(0.45), fill=AMBER)
add_text_box(slide, "  Decision Points",
             Inches(9.0), Inches(1.32), Inches(3.9), Inches(0.42),
             font_size=Pt(13), bold=True, color=WHITE)

questions = [
    "Approve Phase 1 deployment budget?",
    "Confirm production server location (on-premise vs cloud)?",
    "Identify Phase 2 database integration owner?",
    "Set official go-live target date?",
    "Approve staff training schedule?",
    "Assign ClaimsPro System Administrator?",
]
for i, q in enumerate(questions):
    add_rect(slide, Inches(9.05), Inches(1.9) + i * Inches(0.58),
             Inches(3.75), Inches(0.5), fill=WHITE,
             line_color=AMBER, line_width=Pt(0.8))
    add_text_box(slide, "?  " + q,
                 Inches(9.1), Inches(1.93) + i * Inches(0.58),
                 Inches(3.6), Inches(0.44),
                 font_size=Pt(9.8), color=RGBColor(0x80, 0x50, 0x00), wrap=True)


# ═══════════════════════════════════════════════════════════════════════════════
#  SLIDE 14 – CLOSING / THANK YOU
# ═══════════════════════════════════════════════════════════════════════════════
slide = prs.slides.add_slide(BLANK)
add_rect(slide, 0, 0, SLIDE_W, SLIDE_H, fill=NAVY)
add_rect(slide, 0, Inches(3.0), SLIDE_W, Inches(0.08), fill=AMBER)
add_rect(slide, Inches(9.5), 0, Inches(3.83), SLIDE_H, fill=BLUE)

add_text_box(slide, "Thank You",
             Inches(0.5), Inches(1.0), Inches(8.8), Inches(1.1),
             font_size=Pt(54), bold=True, color=WHITE)
add_text_box(slide, "ClaimsPro — Transforming Claims Operations",
             Inches(0.5), Inches(2.1), Inches(8.8), Inches(0.6),
             font_size=Pt(20), color=RGBColor(0xA8, 0xC8, 0xF0))
add_text_box(slide, "Questions & Discussion",
             Inches(0.5), Inches(3.25), Inches(8.8), Inches(0.55),
             font_size=Pt(16), color=AMBER, bold=True)

# Summary bullets
summary = [
    "✔  End-to-end digital claim lifecycle — from FNOL to payout decision",
    "✔  Role-based control with full audit trail and business rule enforcement",
    "✔  Real-time dashboard for operational and executive oversight",
    "✔  Scalable REST architecture ready for enterprise integration",
    "✔  Phase 1 ready for deployment — minimal infrastructure requirements",
]
for i, s in enumerate(summary):
    add_text_box(slide, s,
                 Inches(0.6), Inches(4.0) + i * Inches(0.47), Inches(8.7), Inches(0.44),
                 font_size=Pt(11.5), color=WHITE)

# Right panel
add_text_box(slide, "Contact",
             Inches(9.7), Inches(1.5), Inches(3.4), Inches(0.38),
             font_size=Pt(12), color=RGBColor(0xA8, 0xC8, 0xF0), italic=True)
add_text_box(slide, "ClaimsPro Team",
             Inches(9.7), Inches(1.9), Inches(3.4), Inches(0.45),
             font_size=Pt(15), bold=True, color=WHITE)
add_text_box(slide, "sagineni.s@techbulls.co.in",
             Inches(9.7), Inches(2.4), Inches(3.4), Inches(0.38),
             font_size=Pt(11), color=RGBColor(0xA8, 0xC8, 0xF0))

add_text_box(slide, "Running on",
             Inches(9.7), Inches(3.5), Inches(3.4), Inches(0.35),
             font_size=Pt(11), color=RGBColor(0xA8, 0xC8, 0xF0), italic=True)
add_text_box(slide, "http://localhost:9090",
             Inches(9.7), Inches(3.85), Inches(3.4), Inches(0.42),
             font_size=Pt(13), bold=True, color=AMBER)
add_text_box(slide, "Spring Boot 2.7  |  Java 17\nApache Tomcat 9",
             Inches(9.7), Inches(4.35), Inches(3.4), Inches(0.55),
             font_size=Pt(10.5), color=RGBColor(0xA8, 0xC8, 0xF0))

add_text_box(slide, "Confidential — Prepared for Executive Leadership",
             Inches(0.5), Inches(7.0), Inches(9.0), Inches(0.35),
             font_size=Pt(9), italic=True, color=RGBColor(0x60, 0x80, 0xA0))

footer(slide, 14)


# ── Save ──────────────────────────────────────────────────────────────────────
out_path = r"c:\ClaudeCodeAI\Claims\ClaimsPro_Executive_Presentation.pptx"
prs.save(out_path)
print(f"Saved: {out_path}")
