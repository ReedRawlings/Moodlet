# Product Requirements Document: Moodlet
## Your Mood-Reflecting Companion

---

## Executive Summary

Moodlet is a mood-tracking and journaling app featuring a stylized animal companion that reflects your emotional patterns back to you. Unlike habit-tracking apps that reward task completion, Moodlet rewards *self-awareness* â€” the act of checking in, adding context, and reflecting.

Your Moodlet isn't a pet you feed with productivity. It's a companion that shows you yourself over time â€” and looks cute doing it.

**Core value proposition**: "Check in with yourself. Your Moodlet reflects how you're really doing."

---

## What We Learned From Competitor Research

### What users love about Finch:
- **Non-judgmental tone**: "It treats getting out of bed the same as finishing a project"
- **No punishment for missing days**: "If I skip a day, nothing bad happens"
- **Emotional attachment to the creature**: "It feels like my finch is proud of me, which helps me learn to be proud of myself"
- **Simple enough to use at your worst**: Works when executive function is low
- **Gentle progression**: Adventures, discoveries, personality development over time
- **Customization as reward**: Outfits, accessories, environments purchased with earned currency
- **Inclusive design**: Pronouns, pride flags, accessibility options

### What users love about Daylio:
- **Speed**: "Two taps to log a mood" â€” can be done in under 5 seconds
- **No writing required**: Icon-based logging removes friction
- **Pattern recognition**: "I could see clear trends in my moods and what triggered them"
- **Year in Pixels**: Visual representation of mood over time is beloved
- **Activity correlation**: Shows which activities correlate with which moods
- **Works at your worst**: Simple enough to use during depressive episodes
- **Privacy-first**: Local data storage, no server uploads

### Common pain points to avoid:
- Paywalls that lock core functionality
- Guilt-inducing streaks or "broken streak" notifications
- Waiting 6-12 hours for pet interaction (Finch complaint)
- Cluttered interfaces that bury useful features
- Generic reminders that don't adapt to user behavior

---

## Core Principles

1. **Reward presence, not performance**  
   Points come from showing up and reflecting, not completing tasks.

2. **Accessible at your lowest**  
   Must be usable when depressed, anxious, or exhausted. Minimum viable entry: 2 taps.

3. **Insight over gamification**  
   The companion and visualizations help you understand your patterns and rhythms, not just collect rewards. The companion mirrors your life activities without emotional judgment.

4. **No punishment, ever**  
   Missing a day has zero negative consequences. The companion waits without judgment.

5. **Privacy by default**  
   Data stays on device. Optional cloud sync for backup only.

---

## Phase 1: Foundation (MVP)
*Goal: Core loop that's simple, usable, and emotionally resonant*

### 1.1 Companion System

**Companion Creation (during onboarding)**
- Hatch from egg after first mood log
- Egg color determines base color of Moodlet
- Species is revealed on hatch (random from starter options, or chosen)
- Free tier: 1 species (Cat â€” most universally appealing)
- Premium: All 6 species unlocked

**Available Species** (all share unified body proportions):
| Species | Personality Vibe | Notes |
|---------|------------------|-------|
| Cat | Cozy, independent | Free starter |
| Bear | Sturdy, comforting | Premium |
| Bunny | Soft, gentle | Premium |
| Frog | Quirky, calm | Premium |
| Fox | Warm, curious | Premium |
| Penguin | Resilient, cheerful | Premium |

**Companion Behavior**
- Expression reflects your *recent* mood trend (3-day rolling average, not single entries)
- 5 expression states: Content, Happy, Tired, Sad, Neutral
- Subtle idle animations (breathing, blinking, ear twitches, tail wags)
- Companion doesn't demand anything â€” just exists alongside you
- Occasional gentle observations based on patterns (Phase 2)

**No death, no decay, no hunger meters. Ever.**

### 1.2 Mood Logging (Core Interaction)

**Quick Mood Entry** (earns 1 point per entry)
- 5-point scale with expressive faces/icons
- Single tap to log
- **Users can log multiple times per day** (morning check-in, afternoon slump, evening reflection)
- Each entry earns points independently
- Optional: add time of day if logging retroactively

**Activity/Context Tags** (earns 1 point)
- Pre-built categories: Sleep, Social, Work, Exercise, Weather, Health, etc.
- Tap to select multiple relevant tags
- Custom tags can be added
- No judgment on what's "good" or "bad"

**Journal Reflection** (earns 2 points)
- Optional free-text entry
- 3 rotating prompts available (can ignore)
- Example prompts:
  - "What's on your mind?"
  - "What influenced your mood today?"
  - "One thing you noticed about yourself"
- Voice-to-text option for low-energy moments

### 1.3 Points & Customization

**Earning Points**
| Action | Points |
|--------|--------|
| Log mood | 1 |
| Add context tags | 1 |
| Write reflection | 2 |
| Complete weekly review | 3 |
| Check-in streak bonuses | Variable (see below) |

**Spending Points**
- Companion colors/skins
- Accessories (hats, glasses, scarves, items)
- Background environments
- Unlockable companion animations

**Shop Design**
- Items visible with prices
- Preview before purchase
- Mix of cheap (5-10 pts) and aspirational (50-100 pts) items
- **Economy target**: Users should unlock 2-3 items in first week with moderate engagement
- New items added periodically

**Points Economy Modeling** (to be refined during development):
- Moderate user (2 entries/day, occasional journaling): ~25-30 pts/week
- Engaged user (3+ entries/day, regular journaling): ~40-50 pts/week
- Casual user (4-5 entries/week, minimal journaling): ~8-12 pts/week
- Balance shop prices to make casual users feel progress, engaged users feel rewarded


### 1.4 Streak Rewards (Positive Reinforcement Only)

**Philosophy**: Celebrate consistency without punishing breaks.

**Streak Bonuses**
| Milestone | Reward | Notes |
|-----------|--------|-------|
| 3 days | +2 bonus points | "You've checked in 3 days in a row!" |
| 7 days | +5 bonus points + special badge | Unlock exclusive "Week Warrior" badge |
| 14 days | +10 bonus points | Access to streak-exclusive shop section |
| 30 days | Special background or accessory | Unlocks "Month Milestone" cosmetic |
| 100 days | Rare companion animation | Celebratory animation unlock |

**Breaking Streaks**
- **No punishment**: Missing a day = zero negative consequences
- **No guilt messaging**: Never show "You broke your streak!"
- **Gentle return**: "Welcome back! Your Moodlet missed you" (but Moodlet looks happy to see you)
- **Streak continues**: If user returns within 48 hours, streak "pauses" rather than resets (optional grace period)

**Streak-Exclusive Shop**
- Special items only available to users who've hit certain milestones
- Items remain available even if streak breaks (once unlocked, stays unlocked)
- Gives long-term users something to aspire to without punishing newer users

**Notification Strategy**
- Never mention streaks in notifications
- No "Don't break your streak!" messaging
- Positive framing only: "Ready for today's check-in?" not "You haven't logged today"

### 1.5 Basic Insights

**Mood Calendar**
- "Year in Pixels" style grid showing mood by day
- Color-coded by mood level
- Tap any day to see that day's entries

**Simple Trends**
- Average mood this week vs. last week
- Most common activity tags
- Days with most/fewest entries

### 1.6 Technical Requirements (Phase 1)

- **Platform**: iOS (SwiftUI)
- **Minimum iOS**: 16.0+
- **Data storage**: SwiftData (local-first)
- **No account required** to start
- **Notifications**: 
  - User sets schedule during onboarding
  - Local notifications (no server needed)
  - Customizable times (morning/afternoon/evening)
  - Gentle copy, never guilt-based
- **Privacy**: No analytics beyond anonymous crash reporting (TelemetryDeck or similar)
- **Accessibility**: VoiceOver, Dynamic Type, Reduce Motion support from day 1

---

## Phase 2: Depth
*Goal: Richer insights, more personalization, companion personality*

### 2.1 Enhanced Insights

**Activity-Mood Correlations**
- "You tend to feel better on days you tagged 'outside'"
- "Work + poor sleep often correlates with lower mood"
- Visual charts showing correlations

**Time-of-Day Patterns**
- Morning vs. afternoon vs. evening mood trends
- "Your mood typically dips around 3pm"

**Weekly Summary**
- Auto-generated reflection on the past 7 days
- Highlights and lowlights
- Earns 3 points for reviewing

### 2.2 Companion Personality

**Personality Development**
- Companion develops traits based on your patterns
- Example: If you often journal late at night â†’ "Night Owl" trait
- If you frequently log outdoors activity â†’ "Nature lover" trait
- Traits affect companion's idle dialogue and animations

**Companion Observations**
- Gentle, non-prescriptive comments based on data
- "You've been checking in more consistently lately"
- "Looks like weekends have been tough recently"
- Never tells you what to do â€” just reflects

### 2.3 Expanded Customization

**Companion Evolution**
- After ~30 days of use, companion can "grow" into variant forms
- Evolution based on engagement patterns, not "good" vs. "bad" moods
- Multiple evolution paths (all neutral â€” no "worse" evolutions)

**Environment System**
- Unlock different environments (cozy room, garden, night sky, etc.)
- Environments shift subtly based on time of day or season

**Accessories Expansion**
- Seasonal items
- Items that reference discovered personality traits

### 2.4 Journaling Enhancements

**Prompt Categories**
- Gratitude prompts
- Self-compassion prompts
- Curiosity prompts
- Reflection prompts
- User can favorite/hide specific prompts

**Photo Attachment**
- Add one photo per entry
- Optional â€” no pressure

**Voice Memos**
- Record instead of type
- Transcription optional

### 2.5 Technical Requirements (Phase 2)

- **iCloud Sync**: Optional backup/restore
- **Widgets**: Home screen widget for quick mood log
- **Shortcuts Integration**: "Hey Siri, log my mood"
- **Export**: CSV/PDF export of mood data

---

## Phase 3: Connection
*Goal: Optional social features, deeper therapeutic tools*

### 3.1 Social Features (All Optional)

**Companion Visiting**
- Friends can "visit" each other's companions
- Send "good vibes" (small encouraging messages/animations)
- No pressure â€” purely opt-in

**Accountability Partners**
- Optionally share weekly summary with a trusted person
- They see: general mood trend + whether you checked in
- They don't see: journal content or specific entries

### 3.2 Therapeutic Tools

**Guided Journeys**
- Multi-day themed reflection sequences
- Examples: "Processing a difficult week", "Building self-compassion"
- Unlock with points or included in premium

**Breathing Exercises**
- Simple guided breathing (box breathing, 4-7-8, etc.)
- Earns 1 point per use
- Companion does breathing animation alongside you

**Grounding Exercises**
- Quick 3-3-3 grounding (3 things you see, hear, feel)
- For moments of anxiety

### 3.3 Advanced Insights

**Long-term Trends**
- Month-over-month comparisons
- Year-in-review summary
- "This time last year, you were..."

**Custom Tracking**
- User-defined metrics (sleep hours, medication, pain level, etc.)
- Correlate custom metrics with mood

### 3.4 Premium Features (Optional Subscription)

**Free version includes:**
- All core mood logging
- Basic customization (starter items)
- Basic insights
- Unlimited entries

**Premium adds:**
- Full shop access (exclusive items)
- Advanced insights and correlations
- Guided journeys
- Priority access to new features
- Custom themes
- iCloud sync for backup

**One-Time Purchases** (alternative/additional to subscription):
- Deluxe Cosmetics Pack: $9.99 (50+ exclusive items)
- Seasonal Theme Packs: $4.99 each (holiday items, seasonal backgrounds)
- Species Unlock Pack: $14.99 (unlock all 6 species permanently)

**Pricing**:
- Monthly subscription: $4.99/month
- Annual subscription: $29.99/year (save 50%)
- Lifetime unlock: $79.99 (optional)

**Monetization Philosophy**: 
Our primary goal is helping users build better self-awareness and lead better lives. Premium features enhance the experience but never gate core mental health functionality. Revenue supports ongoing development and keeps the app sustainable without compromising our values.

---

## Design Principles

### Visual Design
- Soft, rounded shapes
- Muted, calming color palette (not sterile â€” warm)
- Companion should feel handcrafted, not corporate
- Generous whitespace
- Dark mode support

### Interaction Design
- Maximum 2 taps to log a mood
- No mandatory anything â€” every feature is optional
- Animations should be subtle and calming
- Haptic feedback for satisfying interactions

### Tone of Voice
- Warm but not saccharine
- Never prescriptive ("You should...")
- Observational ("It looks like...", "Lately you've...")
- Celebrates presence, not achievement
- Normalizes difficult emotions

### Accessibility
- VoiceOver support
- Dynamic type support
- Color blind-friendly palette options
- Reduce motion option

---

## Success Metrics

### Phase 1
- 7-day retention > 40%
- Average entries per active user > 4/week
- App Store rating > 4.5

### Phase 2
- 30-day retention > 25%
- Premium conversion > 5%
- Average session length > 90 seconds

### Phase 3
- 90-day retention > 15%
- Social feature adoption > 20% of users
- NPS > 50

---

## Design Decisions

### 1. Companion Type: Stylized Animals (Moodlets)

**Decision**: Stylized animals with unified body shapes for easy item/wearable compatibility.

**Rationale**: 
- Animals create immediate emotional connection
- Unified silhouette means one hat fits all species
- "Moodlet" becomes both the app name AND the creature type ("my Moodlet")

**Species Ideas** (all share similar rounded body proportions):
- Cat (classic, cozy vibes)
- Bear (comforting, sturdy)
- Bunny (soft, gentle)
- Frog (quirky, calm)
- Fox (warm, clever)
- Penguin (resilient, adorable)

**Art Direction**:
- Rounded, soft shapes
- Simple features (dots for eyes, minimal detail)
- 2-3 head tall proportions (chibi-esque)
- Consistent "shoulder" width across species for wearables
- Flat/vector style for crisp scaling

---

### 2. Onboarding: First Mood Log IS the Onboarding

**Decision**: Integrate first mood log into onboarding flow. User logs a mood before they even finish setup.

**Flow** (target: 45-60 seconds):

```
Screen 1: "Welcome to Moodlet"
         [Warm illustration, single "Let's begin" button]

Screen 2: "First, how are you feeling right now?"
         [5 mood faces â€” user taps one]
         â†’ This IS their first entry

Screen 3: "What's been part of your day?"
         [6-8 common activity chips: sleep, work, social, etc.]
         â†’ Optional, can skip

Screen 4: "Now, let's hatch your Moodlet"
         [Egg with color picker]
         [Tap to hatch â†’ species revealed]

Screen 5: "What should we call them?"
         [Name input]
         [Pronoun selector: they/she/he/custom]

Screen 6: "When should we check in?"
         [Time picker for daily reminder]
         [Option: "I'll decide later"]

Screen 7: Moodlet appears with first mood reflected
         "Nice to meet you. You've already logged your first mood."
         [Enter app]
```

**Key principle**: They've accomplished something before they even "start."

---

### 3. Notification Strategy: User-Set Check-In Schedule

**Decision**: Users choose their check-in times during onboarding. Notifications are framed as the check-in itself, not a reminder about the app.

**Notification Copy Examples**:
- Morning: "Good morning â€” how are you starting the day?"
- Afternoon: "Checking in â€” how's it going?"  
- Evening: "Winding down â€” how was today?"
- Neutral: "Your Moodlet is here when you're ready"

**Rules**:
- Never mention streaks in notifications
- Never guilt ("You haven't logged in 3 days!")
- Notifications can be snoozed or rescheduled easily
- "Quiet hours" respected automatically
- After 7 days of no opens, notifications reduce frequency (not increase)

**Optional Adaptive Notifications** (Phase 2):
- Learn when user typically logs and adjust timing
- "You usually check in around now"

---

### 4. Premium Balance: Generous Free, Cosmetics as Premium

**Decision**: Core experience is fully free. Premium unlocks expanded cosmetics and convenience features.

**Free Tier Includes**:
- Unlimited mood logging
- All context/activity tags
- Full journaling (text, prompts)
- Basic insights (mood calendar, simple trends)
- 1 starter Moodlet species
- ~10 basic accessories and backgrounds
- Weekly summaries
- Data export (CSV)

**Premium Tier Adds**:
- Full cosmetics shop (100+ items)
- All 6 Moodlet species
- Exclusive seasonal items
- Advanced insights (correlations, time-of-day patterns)
- Guided reflection journeys
- Custom themes and app icons
- iCloud backup/sync
- Priority support

**Pricing**:
- Monthly: $4.99
- Annual: $29.99 (save 50%)
- Lifetime: $79.99 (optional, if we want)

**Philosophy**: A free user should never feel like they're missing the "real" app. Premium is for people who want *more*, not for unlocking basics.

---

### 5. Name: Moodlet (Confirmed)

**Decision**: Keep "Moodlet" â€” it works on multiple levels.

**Why it works**:
- Sounds like a creature type ("I have a Moodlet")
- Contains "mood" â€” clear purpose
- "-let" suffix implies small/cute (booklet, droplet, piglet)
- Memorable, easy to spell
- Available as a trademark? (needs verification)
- App Store searchability: "mood" is a strong keyword

**Naming in-app**:
- The app: "Moodlet"
- The creature: "your Moodlet" or just by its given name
- The species: "a cat Moodlet", "a frog Moodlet"

---

## Apple Intelligence Integration


### 🚨 CRITICAL: UX Integration Specification Required

**Before implementing ANY Apple Intelligence features, we must define:**

1. **Where do AI features appear in the interface?**
   - Dedicated "Insights" tab?
   - Inline within journal view?
   - Pop-up cards on home screen?
   - Separate "Reflections" section?

2. **When are AI features triggered?**
   - On-demand (user taps "Generate insights")?
   - Automatically after N entries?
   - Background generation with notification?
   - Weekly summary timing?

3. **How are AI vs. human-curated features differentiated?**
   - Visual indicators (sparkle icon, "AI-suggested" label)?
   - Separate sections in UI?
   - Toggle to disable AI features entirely?

4. **What are fallback behaviors?**
   - Device doesn't support Foundation Models (iPhone 14 and below)
   - AI generation fails or times out
   - AI returns empty/nonsensical results
   - User has insufficient data for meaningful insights

5. **How do we handle AI errors gracefully?**
   - Hallucinations (AI suggests patterns that don't exist)
   - Inappropriate responses (despite safety guardrails)
   - User disagrees with AI interpretation
   - Report/feedback mechanism for bad AI outputs

6. **Privacy & transparency**
   - How do we explain on-device processing to users?
   - Opt-in vs opt-out for AI features?
   - Settings panel for AI preferences?

**Action items before Phase 2:**
- [ ] Create detailed wireframes for each AI feature touchpoint
- [ ] Define AI feature discoverability (how users learn about them)
- [ ] Build AI response validation layer (sanity checks before showing to user)
- [ ] Design fallback content library for non-AI devices
- [ ] User testing with AI features to validate usefulness vs. creepiness factor

**Remember**: AI features should enhance the experience, not define it. Core app must work beautifully without any AI.

---

Apple's Foundation Models framework provides on-device AI capabilities that are *perfect* for Moodlet. Key benefits:
- **Free inference**: No API costs, no server infrastructure
- **Privacy-first**: All processing happens on-device
- **Works offline**: No internet required
- **Native Swift API**: Easy integration with just a few lines of code

### What Other Apps Are Doing

Stoic (journaling app) can now suggest contextual journaling prompts that invite reflection, as well as tailored starting phrases to help users kick-start an entry. Users can also reflect back on their past entries with enhanced views powered by the Foundation Models framework, including reading summaries of their journal entries, organizing related entries, and finding entries using the app's improved natural language search.

Day One is using Apple's models to get highlights and suggest titles for entries. The team has also implemented a feature to generate prompts that nudge you to dive deeper and write more based on what you have already written.

### Moodlet Apple Intelligence Features

**Phase 1 (MVP) â€” Writing Tools (Free)**
- System Writing Tools automatically available in journal text fields
- Users can proofread, rewrite, or adjust tone of reflections
- No code required â€” just use standard UITextView/TextField

**Phase 2 â€” Foundation Models Integration**

| Feature | Description | User Benefit |
|---------|-------------|--------------|
| **Smart Journal Prompts** | Generate personalized prompts based on current mood and recent patterns | "You mentioned feeling tired the last 3 days. What's been draining your energy?" |
| **Entry Summaries** | Summarize past journal entries for quick review | See the essence of a month of journaling at a glance |
| **Pattern Insights** | Natural language observations about mood/activity correlations | "You tend to log higher moods on days you tag 'outside' and 'friends'" |
| **Moodlet Observations** | Generate companion dialogue based on user's patterns | The Moodlet says things that feel personal and relevant |
| **Smart Search** | Natural language search through past entries | "Find entries where I talked about work stress" |
| **Weekly Summary Generation** | Auto-generate a reflection on the past week | "This week you checked in 5 times. Your mood averaged 3.2, up from last week..." |

**Phase 3 â€” Advanced Features**

| Feature | Description |
|---------|-------------|
| **Mood Classification** | Analyze journal text to suggest mood if user forgets to log |
| **Activity Extraction** | Auto-suggest activity tags based on journal content |
| **Guided Reflection Journeys** | AI-guided multi-day reflection sequences |
| **Conversation with Moodlet** | Simple back-and-forth about your patterns (not a therapist, just curious) |

### Implementation Notes

The on-device model, though impressive with 3 billion parameters, is optimized for specific tasks like summarization, extraction, and classification, and is not suitable for world knowledge or advanced reasoning. Break down tasks into smaller pieces to maximize its effectiveness.

**Best suited for Moodlet:**
- Summarization (journal entries, weekly reviews)
- Classification (mood from text, activity extraction)
- Short text generation (prompts, Moodlet dialogue)
- Pattern description (turning data into natural language)

**Not suited for:**
- Complex reasoning or advice-giving
- Therapy or mental health guidance
- Factual knowledge questions

### Safety Considerations

"With the Foundation Models framework, prompts and reflections now adapt to a user's state of mind, so the experience feels personal and evolves day by day... all insights and prompts generated without anything ever leaving their device."

- All AI features must be framed as observation, never prescription
- Moodlet should never give mental health advice
- If user logs crisis-level moods, show resources â€” don't generate AI responses
- Built-in Apple safety guardrails help, but we add our own layer for sensitive content

### Device Requirements

- iPhone 15 Pro or later (A17 Pro chip+)
- iOS 18.1+ for Writing Tools
- iOS 26+ for Foundation Models framework

**Fallback for older devices:**
- Core app works without AI features
- Prompts come from curated library instead of generated
- Insights shown as data visualizations instead of natural language

---

## Additional Considerations

### HealthKit Integration

**Opportunity**: Automatically pull context data to reduce manual logging friction.

| Data Type | Use Case | User Prompt |
|-----------|----------|-------------|
| Sleep hours | Auto-tag "good sleep" / "poor sleep" | "You slept 5 hours. Want to add that to today's log?" |
| Step count | Auto-suggest "active day" tag | Context for mood patterns |
| Workout data | Auto-tag exercise type | Correlate exercise with mood |
| Mindful minutes | Track meditation | Show meditation's impact on mood |

**Implementation**: 
- Request HealthKit permissions during onboarding (optional)
- Show correlation insights: "On days you sleep 7+ hours, your mood averages 0.8 higher"
- Never require HealthKit â€” always optional enhancement

### Watch App (Phase 3)

Quick mood logging from Apple Watch makes sense for an app about momentary check-ins.

**Watch Features:**
- Complication showing current Moodlet expression
- Quick mood log (5 faces, one tap)
- Optional context tags (simplified set)
- No journaling (too cumbersome on Watch)
- Syncs to iPhone

### Widgets

**Home Screen Widgets:**
- Small: Moodlet face + quick mood log button
- Medium: Moodlet + today's mood history + log button
- Large: Moodlet + week view + patterns

**Lock Screen Widgets:**
- Circular: Moodlet face
- Rectangular: Quick "How are you?" prompt

Widgets are critical for a check-in app â€” reduce friction to near-zero.

### Siri & Shortcuts Integration

Using App Intents, users can:
- "Hey Siri, log my mood as tired"
- "Hey Siri, how have I been feeling this week?"
- Create Shortcuts automations (e.g., log mood at bedtime)

### Localization

**Phase 1**: English only
**Phase 2**: Spanish, French, German, Japanese, Portuguese
**Phase 3**: Full internationalization

Apple Intelligence language support expanding â€” match that rollout.

### Data Export & Portability

Users own their data:
- CSV export of all mood logs
- JSON export of full data (for switching apps)
- PDF "year in review" summary
- Integration with Apple Health (write mood data)

### Accessibility

**From Day 1:**
- VoiceOver full support
- Dynamic Type (all text scales)
- Reduce Motion (disable animations)
- High Contrast mode
- Haptic feedback for interactions

**Moodlet-specific:**
- Moodlet expressions described for VoiceOver
- Color-blind safe palette options
- Audio cues option for mood logging

### Analytics & Privacy

**What we track (anonymized):**
- Crash reports (TelemetryDeck or similar)
- Feature usage (which features are used, not what's logged)
- Retention metrics (days active, not content)

**What we never track:**
- Mood data content
- Journal text
- Any personal information
- Activity tags chosen

**Privacy statement**: "Your moods and thoughts never leave your device unless you choose to export them."

### App Store Optimization

**Category**: Health & Fitness (primary), Lifestyle (secondary)

**Keywords**: mood tracker, journal, mental health, self care, mood diary, wellness, mindfulness, mood log, daily journal, emotional health

**Competitor apps to study rankings:**
- Finch
- Daylio
- Bearable
- Pixels
- Reflectly

### Monetization Backup Plans

If premium conversion is low:
- Tip jar option
- Seasonal cosmetic packs (one-time purchase)
- "Supporter" badge for one-time purchase
- Never: ads in a mental health app

---

## Appendix: Competitive Landscape

| App | Strength | Weakness | Our Differentiation |
|-----|----------|----------|---------------------|
| Finch | Emotional attachment, non-judgmental | Habit-task focused, waiting times | Focus on reflection, not tasks |
| Daylio | Speed, pattern insights | No emotional connection | Companion adds warmth |
| Bearable | Detailed health tracking | Complex, clinical feel | Simpler, more accessible |
| Pixels | Beautiful year view | Minimal features | More depth + companion |

---


---

## Implementation Priorities & Open Questions

### Must Define Before Building Core App

**1. Activity → Animation Mapping System**
- How many activity states do we need? (10? 20? 50?)
- Which activities are most common and should have unique animations?
- What's the "default" state when multiple activities are tagged?
- How long does an activity animation persist? (Until next log? 24 hours?)
- **ACTION**: Create comprehensive activity list and prioritize top 15-20 for Phase 1

**2. Points Economy Mathematical Model**
- Build spreadsheet modeling different user archetypes:
  - Casual (3-4 logs/week, no journaling)
  - Regular (1-2 logs/day, occasional journaling)
  - Engaged (2-3 logs/day, frequent journaling)
- Test if shop prices create satisfying unlock cadence for all types
- Validate first-week experience (target: 2-3 unlocks for regular users)
- **ACTION**: Complete economy spreadsheet before finalizing shop prices

**3. Data Model Schema**
- Define SwiftData entities and relationships
- Decide on data retention policy (keep all entries forever? Archive after 1 year?)
- Plan for migration strategy when schema changes in future versions
- Define accessory equip/unequip rules (one hat at a time? multiple accessories?)
- **ACTION**: Write out complete data model before coding begins

**4. Companion Animation Technical Approach**
- Pixel art sprite sheets: How many frames per activity?
- State transition timing (instant swap vs. fade vs. morphing?)
- Memory management for multiple animation states
- Loading strategy (all in memory vs. lazy load?)
- **ACTION**: Build animation prototype to test technical feasibility

**5. Notification Copy & Strategy**
- Write complete set of notification messages (at least 20 variations to avoid repetition)
- Define notification frequency and timing logic
- Plan adaptive notification system (Phase 2)
- Handle notification permissions denial gracefully
- **ACTION**: Draft full notification copy library before implementing notification system

### Open Design Questions

**UI/UX Questions:**
- Where does the companion live on screen? (Dedicated home tab? Floating? Center of every view?)
- How prominent is mood logging vs. companion vs. insights? (Information hierarchy)
- What's the "home screen" of the app? (Companion first? Quick log first?)
- How do users discover the shop? (Dedicated tab? Companion customization button?)

**Behavioral Questions:**
- Should companion acknowledge when user hasn't logged in a while?
- What if user logs the same activity 10 times in one day? (Prevent gaming the system?)
- Do we show activity history on the companion screen or only in insights?

**Technical Questions:**
- How to handle app updates that add new accessories? (Auto-unlock for existing users? New shop items?)
- Export format for mood data—what do users actually need?
- Should we support importing data from competitors (Daylio, Finch)?

### Deferred to Phase 2+
- All Apple Intelligence features (Foundation Models)
- Social features (visiting companions, accountability partners)  
- Advanced insights (correlations, time-of-day patterns)
- Guided journeys and therapeutic tools
- Watch app, Widgets, Shortcuts integration

## Next Steps

1. Validate companion concept with quick prototype
2. Design core mood-logging flow (Figma)
3. Build Phase 1 MVP in SwiftUI
4. Closed beta with 20-50 users
5. Iterate based on feedback before public launch
