# ArtVault: Creative Community Reputation System

A decentralized platform built on Stacks blockchain for tracking artistic contributions and building creative reputation within artist communities.

## Overview

ArtVault is a smart contract that enables artists to register, submit artwork, provide reviews, and participate in collaborations while earning creativity scores based on their contributions. The system implements a reputation mechanism that rewards active participation and tracks artistic engagement over time.

## Features

- **Artist Registration**: Artists can register and create portfolios on the platform
- **Artwork Submission**: Submit creative works and earn creativity points
- **Peer Reviews**: Provide feedback on other artists' work
- **Collaborations**: Participate in collaborative projects
- **Dynamic Reputation**: Creativity scores that diminish over time without activity
- **Multiple Art Mediums**: Support for different types of creative contributions

## Smart Contract Architecture

### Data Structures

#### Artist Portfolio
Each registered artist has a portfolio containing:
- `creativity-score`: Total accumulated creativity points
- `artworks-created`: Number of artworks submitted
- `reviews-given`: Number of reviews provided to other artists
- `last-creation`: Block height of last creative activity
- `collaborations`: Number of collaborative projects joined

#### Art Mediums
The platform supports three types of creative activities:
- **Creation** (10 inspiration points): Submitting original artwork
- **Review** (5 inspiration points): Providing constructive feedback
- **Collaboration** (15 inspiration points): Participating in group projects

## Usage

### For Artists

#### 1. Register as an Artist
```clarity
(contract-call? .artvault register-artist)
```

#### 2. Submit Artwork
```clarity
(contract-call? .artvault submit-artwork)
```

#### 3. Provide Reviews
```clarity
(contract-call? .artvault provide-review)
```

#### 4. Join Collaborations
```clarity
(contract-call? .artvault join-collaboration)
```

### Read-Only Functions

#### Get Artist Portfolio
```clarity
(contract-call? .artvault get-artist-portfolio 'SP1234...)
```

#### Get Medium Inspiration Values
```clarity
(contract-call? .artvault get-medium-inspiration "creation")
```

#### Get Active Creativity Score
```clarity
(contract-call? .artvault get-active-creativity 'SP1234...)
```

### For Gallery Owners

#### Update Medium Values
Only the contract owner can adjust inspiration values for different mediums:
```clarity
(contract-call? .artvault update-medium-value "creation" u15)
```

## Reputation System

### Creativity Score Calculation
- Artists earn points based on their activities
- Each medium has a different inspiration value
- Scores are cumulative but subject to diminishing returns

### Activity-Based Diminishing
The system implements a unique feature where creativity scores diminish over time based on inactivity:
- The longer since last creative activity, the lower the effective creativity score
- This encourages consistent engagement and prevents gaming the system
- Formula: `active_score = base_score / (stagnation_period / 1000)`

## Error Codes

- `u100`: Owner access required
- `u101`: Artist not found
- `u102`: Forbidden operation
- `u103`: Artist already registered
- `u104`: Portfolio missing (artist not registered)
- `u105`: Invalid medium type
- `u106`: Invalid parameters

## Security Features

- **Access Control**: Admin functions restricted to gallery owner
- **Input Validation**: All medium types validated against supported list
- **Bounds Checking**: Maximum inspiration values capped at 1000
- **Duplicate Prevention**: Artists cannot register multiple times

## Installation & Deployment

### Prerequisites
- Stacks blockchain environment
- Clarity smart contract deployment tools

### Deployment Steps
1. Deploy the contract to Stacks blockchain
2. The deploying address becomes the gallery owner
3. Default medium values are automatically set during deployment

### Testing
The contract can be tested using Clarinet or similar Clarity testing frameworks:

```bash
clarinet test
```

## Contributing

### Adding New Features
- New art mediums can be added by the gallery owner
- Medium inspiration values are configurable
- Portfolio structure can be extended for additional metrics

### Code Style
- Follow Clarity best practices
- Use descriptive function and variable names
- Include comprehensive error handling
- Document all public interfaces

