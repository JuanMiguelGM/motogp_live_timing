# AGENTS.md — MotoGP Live Timing Board

This document provides guidance to AI coding agents working with this repository.

## What is this project?

A real-time MotoGP live timing dashboard that shows all bikes on a track map during races, qualifying, and practice sessions. It displays timing data, positions, gaps, sector times, and other telemetry information sourced from the MotoGP PulseLive API. MotoGP premier class only.

## Development Commands

### Setup
```bash
bin/setup       # Install dependencies and prepare database
bin/dev         # Start the development server (uses Procfile.dev)
```

### Testing
```bash
bundle exec rspec                    # Run full test suite
bundle exec rspec spec/models        # Run model specs only
bundle exec rspec spec/requests      # Run request specs only
bundle exec rspec spec/system        # Run system/feature specs
```

### Code Quality
```bash
bundle exec rubocop                  # Run linter
bundle exec rubocop -a               # Auto-fix offenses
```

### Database
```bash
bin/rails db:migrate                 # Run pending migrations
bin/rails db:seed                    # Seed sample data from MotoGP API
bin/rails db:reset                   # Drop, create, migrate, seed
```

### Data Sync
```bash
rake motogp:sync_season[2026]        # Sync season, events, sessions
rake motogp:sync_riders[EVENT_UUID]  # Sync riders for an event
rake motogp:rebuild_tracks           # Rebuild SVG track maps from seed data
```

## Architecture Overview

- **Framework**: Ruby on Rails 8.1 (Ruby 4.0)
- **Database**: SQLite (WAL mode, single-user app)
- **CSS**: Tailwind CSS v4
- **Real-time**: ActionCable (WebSockets) for pushing live data to the browser
- **JavaScript**: Stimulus controllers via importmap-rails (no build step)
- **Asset pipeline**: Propshaft
- **Testing**: RSpec with FactoryBot, shoulda-matchers
- **Linting**: RuboCop with rubocop-rails and rubocop-rspec

### Core Domain Models
- **Constructor** — Manufacturer (Ducati, Yamaha, Honda, KTM, Aprilia)
- **Team** — Racing team, belongs_to constructor
- **Circuit** — Track layout data (name, country, SVG track coordinates)
- **Category** — MotoGP, Moto2, Moto3
- **Season** — Racing season (year)
- **Event** — Grand Prix (name, circuit, dates), was "Race" in F1 project
- **Rider** — Rider info (name, number, team), was "Driver" in F1 project
- **Session** — Practice, Qualifying, Sprint, Race within an Event
- **TimingEntry** — Live timing per rider per session (position, gap, sectors, tire, speed, laps, status)
- **BikePosition** — Estimated x/y coordinates on track map, was "CarPosition" in F1 project
- **RaceDirectionMessage** — Race direction messages, was "RaceControlMessage" in F1 project
- **WeatherSnapshot** — Weather conditions per session

### Key Features
- Live track map with estimated bike positions (gap-based, since MotoGP API has no GPS)
- Timing tower (P, Rider, Int, Gap, Last, Best, S1-S3, Tire, Pit, Speed, Laps, Status)
- Sector times with color coding (personal best, session best)
- Tire compound and pit stop tracking
- Race direction message feed
- Session status flags (green, yellow, red, chequered)
- Off-session: next event countdown + last results
- Calendar view with event cards

### Data Source
- **MotoGP PulseLive API** (`api.motogp.pulselive.com/motogp/v1`) — Free, no auth, JSON REST
- Track maps use static seed data since MotoGP API lacks GPS coordinates

### Key Differences from F1 Project
- UUID-based API keys (strings) instead of integer keys
- Constructor model (Ducati, Yamaha, etc.)
- Category model (MotoGP/Moto2/Moto3, premier class only)
- No TeamRadio (not available in MotoGP API)
- Bike positions estimated from timing gaps via TrackPositionEstimator
- Race direction messages instead of race control messages

## Coding Style

- Follow standard Ruby/Rails conventions
- Use RuboCop defaults plus `rubocop-rails` and `rubocop-rspec` extensions
- Write RSpec tests for all new code (models, requests, system tests)
- Keep controllers thin, push logic to models or service objects
- Use Tailwind utility classes for styling; avoid custom CSS unless necessary
- Prefer `frozen_string_literal: true` magic comment in all Ruby files
- Use meaningful variable names; avoid abbreviations
- Stimulus controllers for real-time updates via ActionCable

## Security

- No API keys or tokens in the repository.
- Store any credentials in environment variables or Rails credentials.

## Git Workflow

- Main branch: `main`
- Feature branches: `feature/<description>`
- Bug fixes: `fix/<description>`
- Write meaningful commit messages describing the "why"
