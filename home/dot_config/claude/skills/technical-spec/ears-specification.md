# EARS - Alistair Mavin

*By Daniel Healey*

> What is EARS? The Easy Approach to Requirements Syntax (EARS) is a mechanism to gently constrain textual requirements. The EARS patterns provide structured guidance that enable authors to write high quality textual requirements. There is a set syntax (structure), with an underlying ruleset. A small number of keywor ...

**Source:** https://alistairmavin.com/ears/

---

### What is EARS?

The Easy Approach to Requirements Syntax (EARS) is a mechanism to gently constrain textual requirements. The EARS patterns provide structured guidance that enable authors to write high quality textual requirements.

There is a set syntax (structure), with an underlying ruleset. A small number of keywords are used to denote the different clauses of an EARS requirement. The clauses are always in the same order, following temporal logic. The syntax and the keywords closely match common usage of English and are therefore intuitive.

* * *

### How Was EARS Developed?

Mav and colleagues at Rolls-Royce PLC developed EARS whilst analysing the airworthiness regulations for a jet engine’s control system. The regulations contained high level objectives, a mixture of implicit and explicit requirements at different levels, lists, guidelines and supporting information.

In the process of extracting and simplifying the requirements, Mav noticed that the requirements all followed a similar structure. He found that requirements were easiest to read when the clauses always appeared in the same order. These patterns were refined and evolved to create EARS.

The notation was first published in 2009 and has been adopted by many organisations across the world.

* * *

### Why Use EARS?

System requirements are usually written in unconstrained natural language (NL), which is inherently imprecise. Often, requirements authors are not trained in how to write requirements. During system development, requirements problems propagate to lower levels. This creates unnecessary volatility and risk, impacting programme schedule and cost.

EARS reduces or even eliminates common problems found in natural language requirements. It is especially effective for requirements authors who must write requirements in English, but whose first language is not English. EARS has proved popular with practitioners because it is lightweight, there is little training overhead, no specialist tool is necessary, and the resultant requirements are easy to read.

* * *

### Who Uses EARS?

EARS is used worldwide by large and small organisations in different domains. These include blue chip companies such as Airbus, Bosch,  Dyson, Honeywell, Intel, NASA, Rolls-Royce and Siemens.

The notation is taught at universities around the world including in China, France, Germany, Sweden, UK and USA.

* * *

### The EARS Patterns

#### Generic EARS syntax

The clauses of a requirement written in EARS always appear in the same order. The basic structure of an EARS requirement is:

> While <optional pre-condition>, when <optional trigger>, the <system name> shall <system response>

The EARS ruleset states that a requirement must have: Zero or many preconditions; Zero or one trigger; One system name; One or many system responses.

The application of the EARS notation produces requirements in a small number of patterns, depending on the clauses that are used. The patterns are illustrated below.

* * *

#### Ubiquitous requirements

Ubiquitous requirements are always active (so there is no EARS keyword)

> The <system name> shall <system response>

Example: The mobile phone shall have a mass of less than XX grams.

* * *

#### State driven requirements

State driven requirements are active as long as the specified state remains true and are denoted by the keyword While.

> While <precondition(s)>, the <system name> shall <system response>

Example: While there is no card in the ATM, the ATM shall display “insert card to begin”.

* * *

#### Event driven requirements

Event driven requirements specify how a system must respond when a triggering event occurs and are denoted by the keyword When.

> When <trigger>, the <system name> shall <system response>

Example: When “mute” is selected, the laptop shall suppress all audio output.

* * *

#### Optional feature requirements

Optional feature requirements apply in products or systems that include the specified feature and are denoted by the keyword Where.

> Where <feature is included>, the <system name> shall <system response>

Example: Where the car has a sunroof, the car shall have a sunroof control panel on the driver door.

* * *

#### Unwanted behaviour requirements

Unwanted behaviour requirements are used to specify the required system response to undesired situations and are denoted by the keywords If and Then.

> If <trigger>, then the <system name> shall <system response>

Example: If an invalid credit card number is entered, then the website shall display “please re-enter credit card details”.

* * *

#### Complex requirements

The simple building blocks of the EARS patterns described above can be combined to specify requirements for richer system behaviour. Requirements that include more than one EARS keyword are called Complex requirements.

> While <precondition(s)>, When <trigger>, the <system name> shall <system response>

Example: While the aircraft is on ground, when reverse thrust is commanded, the engine control system shall enable reverse thrust.

Complex requirements for unwanted behaviour also include the If-Then keywords.

[Requirements Engineering & EARS Training](https://alistairmavin.com/requirements-engineering-ears-training/)
