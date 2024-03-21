// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, JsonSchema)]
pub enum RegistryValueData {
    String(String),
    ExpandString(String),
    Binary(Vec<u8>),
    DWord(u32),
    MultiString(Vec<String>),
    QWord(u64),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, JsonSchema)]
#[serde(rename = "Registry", deny_unknown_fields)]
pub struct RegistryConfig {
    /// The path to the registry key.
    #[serde(rename = "keyPath")]
    pub key_path: String,
    /// The name of the registry value.
    #[serde(rename = "valueName")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub value_name: Option<String>,
    /// The data of the registry value.
    #[serde(rename = "valueData")]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub value_data: Option<RegistryValueData>,
}
