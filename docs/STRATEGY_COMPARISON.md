# Multi-Archetype Composition: Strategy Comparison

Quick reference for choosing the right composition strategy.

---

## Strategy Comparison Matrix

| Feature | Layered Composition | Modular Composition | Composite Archetypes |
|---------|---------------------|---------------------|----------------------|
| **Syntax** | `--archetype base --add-features f1,f2` | `--archetypes a1,a2,a3` | `--archetype composite-name` |
| **Use Case** | Primary archetype + enhancements | Multiple equal archetypes | Common pre-tested patterns |
| **Complexity** | Simple | Complex | Simplest |
| **Flexibility** | Medium | Highest | Lowest |
| **Conflict Resolution** | Automatic | Manual/Priority-based | Pre-resolved |
| **User Control** | Medium | High | Low (pre-configured) |
| **Setup Time** | Fast (< 1 min) | Medium (2-3 min) | Fastest (< 30 sec) |
| **Learning Curve** | Easy | Medium | Easiest |
| **Coverage** | 80% of use cases | 5% of use cases | 15% of use cases |
| **Recommended For** | Most users | Power users | Beginners |
| **Implementation Priority** | Phase 1 (HIGH) | Phase 6 (LOW) | Phase 5 (MEDIUM) |

---

## Conflict Resolution Comparison

| Conflict Type | Layered | Modular | Composite |
|---------------|---------|---------|-----------|
| **Port conflicts** | Offset by +100 per feature | Priority-based or user prompt | Pre-assigned |
| **Service names** | Prefix with archetype name | Priority + namespace | Pre-namespaced |
| **Dependencies** | Resolve intersection | Complex resolution | Pre-resolved |
| **Configuration** | Merge with sections | Deep merge with priorities | Pre-merged |
| **User intervention** | 5% of cases | 20% of cases | 0% |

---

## User Experience Comparison

### Layered Composition
```bash
# Example: RAG + Agentic
./create-project.sh --name myapp \
  --archetype rag-project \
  --add-features agentic-workflows

# Result
✓ Base archetype: rag-project
✓ Adding feature: agentic-workflows (offset +100)
✓ Conflicts resolved automatically
✓ Project created in 45 seconds
```

**Pros:**
- Clear primary purpose
- Predictable behavior
- Fast setup
- Minimal decisions

**Cons:**
- Base must be chosen
- Features are secondary

---

### Modular Composition
```bash
# Example: 3 APIs
./create-project.sh --name myapp \
  --archetypes api-service,api-service,api-service \
  --service-names auth,user,payment \
  --priority auth

# Result
⚠ Port conflicts detected (3x port 8000)
  Applying offsets: auth=8000, user=8100, payment=8200
⚠ Service name collisions (3x 'api')
  Renaming: auth-api, user-api, payment-api
✓ Conflicts resolved
✓ Project created in 2m 15s
```

**Pros:**
- Maximum flexibility
- No artificial hierarchy
- Supports complex cases

**Cons:**
- More configuration
- Requires priority specification
- Longer setup time
- Steeper learning curve

---

### Composite Archetypes
```bash
# Example: Pre-configured RAG + Agentic
./create-project.sh --name myapp \
  --archetype rag-agentic-system

# Result
✓ Composite archetype: rag-agentic-system
  - Base: rag-project
  - Feature: agentic-workflows
✓ Pre-resolved conflicts
✓ Custom integrations applied
✓ Project created in 30 seconds
```

**Pros:**
- Zero configuration
- Fastest setup
- Tested & optimized
- Best practices baked in

**Cons:**
- Limited to pre-defined combinations
- Less customization
- Requires maintenance of composites

---

## Implementation Complexity

| Strategy | Implementation Effort | Maintenance Burden | Testing Required |
|----------|----------------------|-------------------|------------------|
| **Layered** | Medium (3 weeks) | Low | Medium |
| **Modular** | High (5 weeks) | Medium | High |
| **Composite** | Low (1 week) | High (per composite) | Low (per composite) |

---

## Recommended Roadmap

### v2.0 Launch (Week 12)
- ✅ Layered Composition (primary strategy)
- ✅ 2-3 Composite Archetypes (common patterns)
- ⚠️ Modular Composition (MVP or skip)

### v2.1 (3 months post-launch)
- ✅ 5+ more Composite Archetypes
- ✅ Enhanced Layered Composition (better conflict detection)
- ⚠️ Full Modular Composition (if user demand exists)

### v2.2+ (6+ months)
- ✅ Custom archetype repositories
- ✅ Archetype marketplace
- ✅ Live archetype updates

---

## Decision Tree

```
Need to combine archetypes?
│
├─ YES → Do you have a primary archetype?
│        │
│        ├─ YES → Use LAYERED COMPOSITION
│        │        --archetype base --add-features f1,f2
│        │
│        └─ NO → Are all archetypes equal?
│                 │
│                 ├─ YES → Use MODULAR COMPOSITION
│                 │        --archetypes a1,a2,a3
│                 │
│                 └─ NO → Reconsider design
│
└─ NO → Is there a pre-configured pattern?
         │
         ├─ YES → Use COMPOSITE ARCHETYPE
         │        --archetype composite-name
         │
         └─ NO → Use single archetype
                  --archetype base
```

---

## Real-World Scenarios

### Scenario 1: AI Application with Monitoring

**Need:** RAG system + observability

**Best Strategy:** Layered Composition
**Reasoning:** RAG is primary, monitoring is enhancement

```bash
./create-project.sh --name ai-app \
  --archetype rag-project \
  --add-features monitoring
```

---

### Scenario 2: Microservices Platform

**Need:** Auth API + User API + Payment API

**Best Strategy:** Modular Composition
**Reasoning:** All APIs are equal, no primary

```bash
./create-project.sh --name platform \
  --archetypes api-service,api-service,api-service \
  --service-names auth,user,payment
```

---

### Scenario 3: Standard RAG + Agentic

**Need:** Common pattern, quick start

**Best Strategy:** Composite Archetype
**Reasoning:** Pre-tested pattern, zero config

```bash
./create-project.sh --name rag-agents \
  --archetype rag-agentic-system
```

---

### Scenario 4: ML Pipeline with Monitoring & MLOps

**Need:** ML Training + 2 features

**Best Strategy:** Layered Composition
**Reasoning:** ML is primary, others enhance

```bash
./create-project.sh --name ml-prod \
  --archetype ml-training \
  --add-features monitoring,mlops
```

---

## Performance Comparison

| Strategy | Project Creation Time | Conflict Detection | Resolution Time | Total |
|----------|----------------------|-------------------|-----------------|-------|
| **Single archetype** | 20s | 0s | 0s | **20s** |
| **Layered (1 feature)** | 25s | 5s | 10s | **40s** |
| **Layered (2 features)** | 30s | 10s | 15s | **55s** |
| **Modular (3 equal)** | 40s | 20s | 60s | **2m** |
| **Composite** | 25s | 0s | 0s | **25s** |

*Times are estimates based on design*

---

## Port Offset Strategy Comparison

### Layered (Recommended)
```
Base archetype:     8000, 9200
Feature 1 (+100):   8100, 9300
Feature 2 (+200):   8200, 9400
Feature 3 (+300):   8300, 9500
```

**Pros:**
- Predictable
- Simple calculation
- Supports up to 10 features (offset 0-900)

**Cons:**
- Fixed offset might not work for all services

---

### Modular (Alternative)
```
Priority 1 (auth):    8000
Priority 2 (user):    8100
Priority 3 (payment): 8200
```

**Pros:**
- User controls priority
- Flexible

**Cons:**
- Requires explicit priority specification
- More complex

---

### Composite (Pre-assigned)
```
RAG API:       8000 (fixed)
Agentic API:   8100 (fixed)
Monitoring:    9090 (fixed)
```

**Pros:**
- Zero calculation
- Documented & tested

**Cons:**
- Cannot customize
- Might conflict with host ports

---

## Recommendation Summary

### For v2.0 Release

**Primary:** Layered Composition (80% of users)
- Covers most use cases
- Easy to use
- Automatic conflict resolution
- Medium implementation effort

**Secondary:** Composite Archetypes (15% of users)
- Common patterns (RAG+Agentic, API+Monitoring)
- Zero configuration
- Fast setup

**Future:** Modular Composition (5% of users)
- Power users only
- Complex scenarios
- v2.1 or later

---

## Implementation Order

1. **Week 1-4:** Layered Composition (core system)
2. **Week 5-6:** First composite archetypes
3. **Week 7-8:** More composites based on demand
4. **Week 9-10:** Modular composition (optional)
5. **Week 11-12:** Testing & polish

---

## Success Criteria by Strategy

### Layered Composition
- ✅ 95% automatic conflict resolution
- ✅ < 1 minute to create project
- ✅ Works with any base + up to 5 features
- ✅ Clear error messages for incompatible combinations

### Composite Archetypes
- ✅ 100% zero-config (no user decisions)
- ✅ < 30 seconds to create project
- ✅ 3-5 composites at launch
- ✅ Clear documentation for each

### Modular Composition
- ✅ Supports 2-5 equal archetypes
- ✅ Priority-based conflict resolution
- ✅ Clear preview of conflicts before creation
- ✅ Interactive resolution for ambiguous cases

---

**Bottom Line:** Start with Layered + Composite. Add Modular if users request it.
