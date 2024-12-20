<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- <a href="https://github.com/mgnfy-view/pay-streams">
    <img src="assets/icon.svg" alt="Logo" width="80" height="80">
  </a> -->

  <h3 align="center">PayStreams</h3>

  <p align="center">
    PayStreams is a payment streaming service supercharged with hooks
    <br />
    <a href="https://github.com/mgnfy-view/pay-streams/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/mgnfy-view/pay-streams/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

PayStreams is a payment streaming service which allows anyone to open token streams directed to any recipient. The recipient can collect the streamed funds over time, or when the stream ends. The stream creator can update, pause, unpause, or cancel the stream as well. Streams can be one-time, or recurring.

Additionally, we introduce hooks, which are functions with custom logic that can be invoked at various points during the stream's lifespan. To opt into hooks, both the streamer and the recipient can set custom vaults with correct functions and hook configuration, and these functions will be invoked by the `PayStreams` contract when certain events occur. Hooks open up a wide array of use cases and customizations, enabling developers to extend the functionality of streams. You can find some hook examples in the `./src/exampleHooks/` folder.

P.S. This project was built for the BuildOn hackathon on Devfolio.

### Built With

- Solidity
- Foundry

<!-- GETTING STARTED -->

## Getting Started

### Prerequisites

Make sure you have git, rust, and foundry installed and configured on your system.

### Installation

Clone the repo,

```shell
git clone https://github.com/mgnfy-view/pay-streams.git
```

cd into the repo, and install the necessary dependencies

```shell
cd pay-streams
forge build
```

Run tests by executing

```shell
forge test
```

That's it, you are good to go now!

<!-- ROADMAP -->

## Roadmap

-   [x] Smart contract development
-   [ ] Unit tests
-   [x] Write a good README.md

See the [open issues](https://github.com/mgnfy-view/pay-streams/issues) for a full list of proposed features (and known issues).

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- CONTACT -->

## Reach Out

Here's a gateway to all my socials, don't forget to hit me up!

[![Linktree](https://img.shields.io/badge/linktree-1de9b6?style=for-the-badge&logo=linktree&logoColor=white)][linktree-url]

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/mgnfy-view/pay-streams.svg?style=for-the-badge
[contributors-url]: https://github.com/mgnfy-view/pay-streams/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/mgnfy-view/pay-streams.svg?style=for-the-badge
[forks-url]: https://github.com/mgnfy-view/pay-streams/network/members
[stars-shield]: https://img.shields.io/github/stars/mgnfy-view/pay-streams.svg?style=for-the-badge
[stars-url]: https://github.com/mgnfy-view/pay-streams/stargazers
[issues-shield]: https://img.shields.io/github/issues/mgnfy-view/pay-streams.svg?style=for-the-badge
[issues-url]: https://github.com/mgnfy-view/pay-streams/issues
[license-shield]: https://img.shields.io/github/license/mgnfy-view/pay-streams.svg?style=for-the-badge
[license-url]: https://github.com/mgnfy-view/pay-streams/blob/master/LICENSE.txt
[linktree-url]: https://linktr.ee/mgnfy.view
