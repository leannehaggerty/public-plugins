/*
 * Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

Genoverse.Track.View = Genoverse.Track.View.extend({
  drawFeature: function (feature, featureContext, labelContext, scale) {
    if (feature.highlight) {
      var position = feature.position[scale];

      featureContext.fillStyle = feature.highlight;
      featureContext.fillRect(position.X, position.Y, position.W, position.H);

      if (feature.labelPosition) {
        labelContext.fillStyle = feature.highlight;
        labelContext.fillRect(feature.x, feature.labelPosition.y, feature.labelPosition.w, feature.labelPosition.h);
      }
    }

    this.base(feature, featureContext, labelContext, scale);
  }
});